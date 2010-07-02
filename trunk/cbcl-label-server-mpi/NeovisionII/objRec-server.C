/*!@file NeovisionII/objRec-Server.C */

// //////////////////////////////////////////////////////////////////// //
// The iLab Neuromorphic Vision C++ Toolkit - Copyright (C) 2000-2005   //
// by the University of Southern California (USC) and the iLab at USC.  //
// See http://iLab.usc.edu for information about this project.          //
// //////////////////////////////////////////////////////////////////// //
// Major portions of the iLab Neuromorphic Vision Toolkit are protected //
// under the U.S. patent ``Computation of Intrinsic Perceptual Saliency //
// in Visual Environments, and Applications'' by Christof Koch and      //
// Laurent Itti, California Institute of Technology, 2001 (patent       //
// pending; application number 09/912,225 filed July 23, 2001; see      //
// http://pair.uspto.gov/cgi-bin/final/home.pl for current status).     //
// //////////////////////////////////////////////////////////////////// //
// This file is part of the iLab Neuromorphic Vision C++ Toolkit.       //
//                                                                      //
// The iLab Neuromorphic Vision C++ Toolkit is free software; you can   //
// redistribute it and/or modify it under the terms of the GNU General  //
// Public License as published by the Free Software Foundation; either  //
// version 2 of the License, or (at your option) any later version.     //
//                                                                      //
// The iLab Neuromorphic Vision C++ Toolkit is distributed in the hope  //
// that it will be useful, but WITHOUT ANY WARRANTY; without even the   //
// implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU General Public License for more details.       //
//                                                                      //
// You should have received a copy of the GNU General Public License    //
// along with the iLab Neuromorphic Vision C++ Toolkit; if not, write   //
// to the Free Software Foundation, Inc., 59 Temple Place, Suite 330,   //
// Boston, MA 02111-1307 USA.                                           //
// //////////////////////////////////////////////////////////////////// //
//
// Primary maintainer for this file: Lior Elazary <elazary@usc.edu>
// $HeadURL: svn://iLab.usc.edu/trunk/saliency/src/NeovisionII/objRec-server.C $
// $Id: objRec-server.C 9205 2007-06-28 17:45:49Z rjpeters $
//

#ifndef OBJREC_SERVER_C_DEFINED
#define OBJREC_SERVER_C_DEFINED

#include "Component/ModelManager.H"
#include "Image/Image.H"
#include "Image/ImageSet.H"
#include "Image/ShapeOps.H"
#include "Image/CutPaste.H"
#include "Image/DrawOps.H"
#include "Image/FilterOps.H"
#include "Image/ColorOps.H"
#include "Image/Transforms.H"
#include "Image/MathOps.H"
#include "Neuro/StdBrain.H"
#include "Neuro/VisualCortex.H"
#include "Neuro/NeuroOpts.H"
#include "Media/MediaSimEvents.H"
#include "Channels/DescriptorVec.H"
#include "Channels/ComplexChannel.H"
#include "Channels/SubmapAlgorithmBiased.H"
#include "Simulation/SimEventQueue.H"
#include "Simulation/SimulationOpts.H"
#include "Simulation/SimEventQueueConfigurator.H"
#include "Neuro/NeuroSimEvents.H"
#include "Learn/Bayes.H"
#include "GUI/DebugWin.H"
#include "ObjRec/MaskBiaser.H"

#include "NeovisionII/nv2_common.h"
#include "NeovisionII/nv2_label_server.h"

#include <signal.h>

int classifyImage(Image<PixRGB<byte> > & img, DescriptorVec &descVec, Bayes &bayesNet, double *prob, double *statSig);
void learnImage(Image<PixRGB<byte> > & img, int cls, DescriptorVec &descVec, Bayes &bayesNet,
                const char *objName = NULL);
int classifyLocation(Point2D &loc, DescriptorVec &descVec, Bayes &bayesNet);
void learnLocation(Point2D &loc, int cls, DescriptorVec &descVec, Bayes &bayesNet,
                   const char *objName = NULL);

Point2D evolveBrain(Image<PixRGB<byte> > &img, DescriptorVec& descVec, int ii=-1);

void biasVC(ComplexChannel &vc, Image<float> &mask);
void unbiasVC(ComplexChannel &vc);

ModelManager *mgr;
XWinManaged *xwin;
bool debug = 0;
bool terminate = false;
struct nv2_label_server* server;

void terminateProc(int s)
{
  LINFO("Ending application\n");
  nv2_label_server_destroy(server);
  terminate = true;
  exit(0);
}


int main(const int argc, const char **argv)
{

  MYLOGVERB = LOG_INFO;
  mgr = new ModelManager("Test ObjRec");

  nub::soft_ref<SimEventQueueConfigurator>
    seqc(new SimEventQueueConfigurator(*mgr));
  mgr->addSubComponent(seqc);

  //our brain
  nub::ref<StdBrain>  brain(new StdBrain(*mgr));
  mgr->addSubComponent(brain);

  mgr->exportOptions(MC_RECURSE);
  mgr->setOptionValString(&OPT_VisualCortexType, "IOC");
  //mgr.setOptionValString(&OPT_VisualCortexType, "I");
  //mgr->setOptionValString(&OPT_VisualCortexType, "GNO");
  //mgr.setOptionValString(&OPT_VisualCortexType, "N");
  //manager.setOptionValString(&OPT_UseOlderVersion, "false");
  // set the FOA and fovea radii
  mgr->setOptionValString(&OPT_SaliencyMapType, "Fast");
  mgr->setOptionValString(&OPT_SMfastInputCoeff, "1");

  mgr->setOptionValString(&OPT_WinnerTakeAllType, "Fast");
  mgr->setOptionValString(&OPT_SimulationTimeStep, "0.2");

  mgr->setModelParamVal("FOAradius", 50, MC_RECURSE);
  mgr->setModelParamVal("FoveaRadius", 50, MC_RECURSE);


  mgr->setOptionValString(&OPT_IORtype, "Disc");

  if (mgr->parseCommandLine(
        (const int)argc, (const char**)argv, "<Network file> <server ip>", 2, 2) == false)
    return 1;

  // catch signals and redirect them to terminate for clean exit:
  signal(SIGHUP, terminateProc); signal(SIGINT, terminateProc);
  signal(SIGQUIT, terminateProc); signal(SIGTERM, terminateProc);
  signal(SIGALRM, terminateProc);

  mgr->start();

  ComplexChannel *cc =
    &*dynCastWeak<ComplexChannel>(brain->getVC());

  //Get a new descriptor vector
  DescriptorVec descVec(*mgr, "Descriptor Vector", "DecscriptorVec", cc);
  //Get  new classifier
  Bayes bayesNet(descVec.getFVSize(), 0);

  //get command line options
  const char *bayesNetFile = mgr->getExtraArg(0).c_str();
  const char *server_ip = mgr->getExtraArg(1).c_str();
  bool train = false;

  int foveaRadius = mgr->getModelParamVal<int>("FoveaRadius", MC_RECURSE);

  printf("Setting fovea to %i, train = %i\n", foveaRadius, train);

  //load the network if testing
  //if (!train)
    bayesNet.load(bayesNetFile);

  descVec.setFoveaSize(foveaRadius);

  xwin  = new XWinManaged(Dims(256,256),
      -1, -1, "ILab Robot Head Demo");


  server = nv2_label_server_create(9930,
        server_ip,
        9931);

  nv2_label_server_set_verbosity(server,1); //allow warnings


  int send_interval = 1;

  while(!terminate)
  {
    double prob = 0, statSig = 0;

    Point2D clickLoc = xwin->getLastMouseClick();
    if (clickLoc.isValid())
      train = !train;

    struct nv2_image_patch p;
    const enum nv2_image_patch_result res =
      nv2_label_server_get_current_patch(server, &p);

    std::string objName = "nomatch";
    if (res == NV2_IMAGE_PATCH_END)
    {
      fprintf(stdout, "ok, quitting\n");
      break;
    }
    else if (res == NV2_IMAGE_PATCH_NONE)
    {
      usleep(10000);
      continue;
    }
    else if (res == NV2_IMAGE_PATCH_VALID &&
       p.type == NV2_PIXEL_TYPE_RGB24)
    {
      printf("Valid patch %s %ix%i\n", p.training_label,
          p.width, p.height);

      //showimg
      Image<PixRGB<byte> > img(p.width, p.height, NO_INIT);
     // unsigned char *imgPtr = const_cast<unsigned char*>
     //   (reinterpret_cast<const unsigned char*>(img.getArrayPtr()));

      memcpy(img.getArrayPtr(), p.data, p.width*p.height*3);

      Image<PixRGB<byte> > objImg = rescale(img, 256, 256);

      int cls = classifyImage(objImg, descVec, bayesNet, &prob, &statSig);
      if (cls != -1 && prob > -150)
        objName = bayesNet.getClassName(cls);
      else
        objName = "nomatch";

      printf("This is %s: Class %i prob %f\n",
          objName.c_str(), cls, prob);


     // if (strcmp(p.training_label, "none") != 0 &&
     //     false) { //training
     if (cls == -1)
     {
        printf("Can you tell me what this is?\n");
        std::getline(std::cin, objName);
        learnImage(objImg, 0, descVec, bayesNet, objName.c_str());
        bayesNet.save(bayesNetFile);
      } else {
        printf("Is this a %s?\n", objName.c_str());

        if (train)
        {
          std::string tmp;
          std::getline(std::cin, tmp);
          if (tmp != "")
            objName = tmp;

          LINFO("Learning %s\n", objName.c_str());
          fflush(stdout);

          learnImage(objImg, 0, descVec, bayesNet, objName.c_str());
          bayesNet.save(bayesNetFile);
        }

      }

    }

    if (objName != "nomatch")
    {
      printf("Object is %s\n", objName.c_str());

      struct nv2_patch_label l;
      l.protocol_version = NV2_LABEL_PROTOCOL_VERSION;
      l.patch_id = p.id;
      snprintf(l.source, sizeof(l.source), "%s",
          "ObjRec");
      snprintf(l.name, sizeof(l.name), "%s", // (%ux%u #%u)",
          objName.c_str());
      //(unsigned int) p.width,
      //(unsigned int) p.height,
      //(unsigned int) p.id);
      snprintf(l.extra_info, sizeof(l.extra_info),
          "%i", (int)statSig);

      if (l.patch_id % send_interval == 0)
      {
        nv2_label_server_send_label(server, &l);

        fprintf(stdout, "sent label '%s (%s)'\n",
            l.name, l.extra_info);
      }
      else
      {
        fprintf(stdout, "DROPPED label '%s (%s)'\n",
            l.name, l.extra_info);
      }
    }

    nv2_image_patch_destroy(&p);
  }

  nv2_label_server_destroy(server);

}

Point2D evolveBrain(Image<PixRGB<byte> > &img, DescriptorVec& descVec, int ii)
{

  nub::ref<StdBrain>  brain = dynCastWeak<StdBrain>(mgr->subComponent("Brain"));
  nub::ref<SimEventQueueConfigurator> seqc =
    dynCastWeak<SimEventQueueConfigurator>(mgr->subComponent("SimEventQueueConfigurator"));
  nub::soft_ref<SimEventQueue> seq  = seqc->getQ();

  LINFO("Evolve Brain");

  if (mgr->started()){    //give the image to the brain

    if (img.initialized())
      {
        //place the image in the inputFrame queue
        rutz::shared_ptr<SimEventInputFrame>
          e(new SimEventInputFrame(brain.get(), GenericFrame(img), 0));
        seq->post(e);
       // brain->input(img, seq);
        descVec.setInputImg(img);
      }

    SimTime end_time = seq->now() + SimTime::MSECS(3.0);

    while (seq->now() < end_time)
    {
      brain->evolve(*seq); //evolve the brain

      // Any new WTA winner?
      if (SeC<SimEventWTAwinner> e = seq->check<SimEventWTAwinner>(brain.get()))
      {
        const Point2D winner = e->winner().p;

        //get the saliency map output
        if (debug)
        {
          if (SeC<SimEventSaliencyMapOutput> smo =
              seq->check<SimEventSaliencyMapOutput>(brain.get(), SEQ_ANY))
          {
            Image<float> img = smo->sm();
            //SHOWIMG(rescale(img, img.getWidth()*16, img.getHeight()*16));
          }
        }
        seq->evolve();

        return winner;
      }


      seq->evolve();
      LINFO("Evolve 1\n");

    }
  }

  return Point2D();

}

int classifyImage(Image<PixRGB<byte> > & img, DescriptorVec &descVec, Bayes &bayesNet, double *prob, double *statSig)
{
  Point2D winner = evolveBrain(img, descVec); //evolve the brain

  //show winner
  if (debug){
    Image<PixRGB<byte> > tmpImg = img;
    drawCircle(tmpImg, winner, 50, PixRGB<byte>(255, 0, 0), 3);
    //SHOWIMG(tmpImg);
  }

  Image<PixRGB<byte> > tmpImg = img;
  drawCircle(tmpImg, winner, 50, PixRGB<byte>(255, 0, 0), 3);
  xwin->drawImage(tmpImg);

  //get the descriptor
  descVec.setFovea(winner);
  descVec.buildRawDV(); //build the descriptor vector

  //get the resulting feature vector
  std::vector<double> FV = descVec.getFV();

  // printf("%i %i ", winner.i, winner.j);
  //  for(uint i=0; i<FV.size(); i++)
  //     printf("%f ", FV[i]);

  //classify

  int cls = -1;
  if (prob != NULL)
    cls = bayesNet.classify(FV, prob);
  else
    cls = bayesNet.classify(FV);

  if (statSig != NULL)
    *statSig = bayesNet.getStatSig(FV, 0); //get the statistical significance
  LINFO("Class %i prob: %f %f\n", cls, *prob, *statSig);


  if (cls == -1) //check for errors
    return -1;
  else
    return cls;

}

void learnImage(Image<PixRGB<byte> > & img, int cls, DescriptorVec &descVec, Bayes &bayesNet,
                const char *objName)
{
  //static int id = 0;
  const int learnNumSacc = 1;
  Point2D winner = evolveBrain(img, descVec); //evolve the brain
  for (int fix=0; fix<learnNumSacc; fix++) //learn the n most salient points in the image
  {
    //show winner
    if (debug){
      Image<PixRGB<byte> > tmpImg = img;
      drawCircle(tmpImg, winner, 50, PixRGB<byte>(255, 0, 0), 3);
      SHOWIMG(tmpImg);
    }

    //get the descriptor
    descVec.setFovea(winner);

    if (debug){
      //SHOWIMG(descVec.getFoveaImage());
    }


    descVec.buildRawDV(); //build the descriptor vector

    //get the resulting feature vector
    std::vector<double> FV = descVec.getFV();


   /* char filename[255];
    sprintf(filename, "results/%i.ppm", id++);
    Raster::WriteRGB(descVec.getFoveaImage(), filename);
    printf("DV %i %s %i %ix%i: ",id, objName, sacc, winner.i, winner.j);
    for(uint i=0; i<FV.size(); i++)
      printf("%f ", FV[i]);
    printf("\n");*/

    printf("OD: '%s' %i %i %i %i ",objName, cls, fix, winner.i, winner.j);
    for(uint i=0; i<FV.size(); i++)
      printf("%f ", FV[i]);
    printf("\n");
    fflush(stdout);


    if (objName != NULL)
    {
      //LINFO("****Learning %s\n", objName);
      bayesNet.learn(FV, objName);
    }
    else
      bayesNet.learn(FV, cls);

     Image<PixRGB<byte> > nullImg;
     winner = evolveBrain(nullImg, descVec); //evolve the biased brain to get a new winner

  }

}



int classifyLocation(Point2D &loc, DescriptorVec &descVec, Bayes &bayesNet)
{

  //get the descriptor
  descVec.setFovea(loc);
  descVec.buildRawDV(); //build the descriptor vector

  //get the resulting feature vector
  std::vector<double> FV = descVec.getFV();


  //classify
  //  printf("FV: ");
  //  for(uint i=0; i<FV.size(); i++)
  //    printf("%f ", FV[i]);
  //  printf("\n");

  int cls = bayesNet.classify(FV);


  if (cls == -1) //check for errors
    return -1;
  else
    return cls;

}

void learnLocation(Point2D &loc, int cls, DescriptorVec &descVec, Bayes &bayesNet,
                   const char *objName)
{

  //get the descriptor
  descVec.setFovea(loc);
  descVec.buildRawDV(); //build the descriptor vector

  //get the resulting feature vector
  std::vector<double> FV = descVec.getFV();

  //      printf("FV: ");
  //      for(uint i=0; i<FV.size(); i++)
  //        printf("%f ", FV[i]);
  //      printf("\n");

  if (objName != NULL)
    bayesNet.learn(FV, objName);
  else
    bayesNet.learn(FV, cls);

}

void biasVC(ComplexChannel &vc, Image<float> &mask)
{
  //Set mean and sigma to bias submap
  MaskBiaser mb(mask, true);
  vc.accept(mb);

  setSubmapAlgorithmBiased(vc);
}


void unbiasVC(ComplexChannel &vc)
{
  Image<float> tmp;
  //Set mean and sigma to bias submap
  MaskBiaser mb(tmp, false);
  vc.accept(mb);

  setSubmapAlgorithmBiased(vc);

}


// ######################################################################
/* So things look consistent in everyone's emacs... */
/* Local Variables: */
/* indent-tabs-mode: nil */
/* c-file-style: "linux" */
/* End: */

#endif
