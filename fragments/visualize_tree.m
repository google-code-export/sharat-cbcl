function varargout = visualize_tree(varargin)
% VISUALIZE_TREE M-file for visualize_tree.fig
%      VISUALIZE_TREE, by itself, creates a new VISUALIZE_TREE or raises the existing
%      singleton*.
%
%      H = VISUALIZE_TREE returns the handle to a new VISUALIZE_TREE or the handle to
%      the existing singleton*.
%
%      VISUALIZE_TREE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUALIZE_TREE.M with the given input arguments.
%
%      VISUALIZE_TREE('Property','Value',...) creates a new VISUALIZE_TREE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before visualize_tree_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to visualize_tree_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help visualize_tree

% Last Modified by GUIDE v2.5 08-Jan-2006 13:21:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visualize_tree_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_tree_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before visualize_tree is made visible.
function visualize_tree_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to visualize_tree (see VARARGIN)

% Choose default command line output for visualize_tree
handles.output = hObject;
if(isempty(varargin))
    error('Needs a tree to visualize');
end;
handles.tree   = varargin{1};
%handles.tree   = post_process_roi(handles.tree);

% Update handles structure
guidata(hObject, handles);
load_list(hObject,handles);
% UIWAIT makes visualize_tree wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = visualize_tree_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in lst_tree.
function lst_tree_Callback(hObject, eventdata, handles)
% hObject    handle to lst_tree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns lst_tree contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lst_tree
idx = get(hObject,'Value');
if(idx > 0)
    set(handles.axs_img,'Visible','on');
    set(handles.axs_roi,'Visible','on');
    axes(handles.axs_img),imshow(handles.images(idx).img);
    %display roi
    roi     =   handles.images(idx).roi;
    [ht,wt] =   size(handles.tree.img);
    img     =   roi_mask(ht,wt,roi);
    axes(handles.axs_roi),imagesc(img),colormap('gray');
end;
 
% --- Executes during object creation, after setting all properties.
function lst_tree_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lst_tree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
    set(hObject,'FontName','FixedWidth');
end

%--------------------------------------------------------
%
%--------------------------------------------------------
function load_list(hobject,handles)
    tree = handles.tree;
    set(handles.lst_tree,'String',[]);
    lst     =   {};
    images  =   [];
    [lst,images,token] = populate_list(lst,images,tree,'',0,0);
    save list lst images;
    set(handles.lst_tree,'String',lst);
    set(handles.lst_tree,'FontName','FixedWidth');
    handles.images = images;
    guidata(hobject,handles);
%end function;

%---------------------------------------------------------
%
%---------------------------------------------------------
function [lst,images,token] = populate_list(lst,images,tree,spacer,parent,token)
    if(isempty(tree.h))
        return;
    end;
    for i = 1:length(tree.h)
        token                        = token+1;
        entry                        = sprintf('%s|___(%d,%d)',spacer,parent,token);        
        lst{length(lst)+1}           = entry;
        idx                          = length(images)+1;
        images(idx).img              = tree.h(i).img;
    	roi                          = tree.h(i).roi;
        roi.x                        = roi.x + tree.roi.x;
    	roi.y                        = roi.y + tree.roi.y;
        tree.h(i).roi                = roi;
        images(idx).roi              = roi;
        new_spacer                   = sprintf('|   %s',spacer);
        [lst,images,token] = populate_list(lst,images,tree.h(i),new_spacer,token,token);
    end;
%end function populate list
