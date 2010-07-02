%---------------------------------------------------------------------------------------
%sharat@mit.edu
%lSizes-cell array containing the dimension of the saliency map at each scale
%xSigma-how leaky the activation is in xy dimension
%sSigma-how leaky the activation is in scale dimension
%pO    -conditional probability matrix (NFTRxNOBJ)
%---------------------------------------------------------------------------------------
function engine=buildEngine(lSizes,xSigma,sSigma,pO)
  HOME='/cbcl/cbcl01/sharat';
  addpath(genpath(fullfile(HOME,'third_party','BNT')));
  addpath(genpath(fullfile(HOME,'ssdb')));
  addpath(genpath(fullfile(HOME,'utils')));
  %-----------------------------------------------------------
  %build the network
   NSCALES = length(lSizes);
   NFTR    = size(pO,1)
   NOBJ    = size(pO,2)
   NLOC    = 0;
   EPS     = 1e-3;
   for l=1:length(lSizes)
     NLOC    = NLOC+prod(lSizes{l});
   end;
   O       = 1;
   L       = 2;
   F_start = 2;
   C_start = F_start+NFTR;
   %-----------------------
   %connectivity	
	dag     = zeros(C_start+NFTR);
	for f=1:NFTR
		dag(O,F_start+f)		=	1;
		dag(F_start+f,C_start+f)=	1;
		dag(L,C_start+f) 		=	1;
	end;
	bnet    = mk_bnet(dag,[NOBJ NLOC ones(1,NFTR)*2 ones(1,NFTR)*(NLOC+1)],...
					  'discrete',[O L F_start+(1:NFTR) C_start+(1:NFTR)]);
	%--------------------------
	%specify CPDs
	%-------------
	%O,L
    bnet.CPD{O} = tabular_CPD(bnet,O,'CPT','unif');
	bnet.CPD{L} = tabular_CPD(bnet,L,'CPT','unif');
	%-------------
	%F	
	for f = 1:NFTR
		tbl   = zeros(NOBJ,2);
		for o = 1:NOBJ
			tbl(o,1)=pO(f,o)
			tbl(o,2)=1-pO(f,o);
		  end;
		  fprintf('Feature :%d\n',f);
		  disp(tbl);
		bnet.CPD{F_start+f}=tabular_CPD(bnet,F_start+f,'CPT',tbl);
	end; 		
	%--------------------------------
	%C : complicated
	for f = 1:NFTR
		fprintf('inserting table for feature:%d\n',f);
		tbl    = zeros(NLOC,2,NLOC+1);
		lstart = 0;
		for ls = 1:NSCALES
			sigmas = sSigma;
			sigmax = xSigma;
            [lx,ly]= meshgrid(1:lSizes{ls}(2),1:lSizes{ls}(1));
			for lp=1:prod(lSizes{ls})
				cstart = 0;
				[ly,lx]=ind2sub(lSizes{ls},lp);
				for cs=1:NSCALES
					for cp=1:prod(lSizes{cs})
						[cy,cx]=ind2sub(lSizes{cs},cp);
						cy      =cy*lSizes{ls}(1)/lSizes{cs}(1);
						cx      =cx*lSizes{ls}(2)/lSizes{cs}(2);
						valx 	=exp((-(cy-ly)^2-(cx-lx)^2)/(2*sigmax*sigmax));
						ds      =ls-cs;
						vals    =max(EPS,exp(-(ds.^2)/(2*sigmas^2)));
						tbl(lstart+lp,1,cstart+cp)= max(EPS,valx*vals);
						tbl(lstart+lp,2,cstart+cp)= EPS;
					end;%end cp
					cstart = cstart+prod(lSizes{cs});
				end;%end cs
				tbl(lp+lstart,1,NLOC+1)= EPS;
				tbl(lp+lstart,2,NLOC+1)= 1;
				tbl(lstart+lp,1,:)=tbl(lstart+lp,1,:)/sum(tbl(lstart+lp,1,:));
				tbl(lstart+lp,2,:)=tbl(lstart+lp,2,:)/sum(tbl(lstart+lp,2,:) );
			end;%end lp
			lstart = lstart+prod(lSizes{ls});
		end;%end ls
		bnet.CPD{C_start+f}=tabular_CPD(bnet,C_start+f,'CPT',tbl,'adjustable',0);
	end %end f
	%engine      = jtree_inf_engine(bnet);
    engine=pearl_inf_engine(bnet,'protocol','parallel','filename','/dev/null','storebel',1);%jtree_inf_engine(bnet);
