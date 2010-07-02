/*!@file NeovisionII/objRec-ServerSift.C */

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
// $HeadURL: svn://iLab.usc.edu/trunk/saliency/src/NeovisionII/objRec-serverSift.C $
// $Id: objRec-serverSift.C 9205 2007-06-28 17:45:49Z rjpeters $
//

#ifndef OBJREC_SERVERSIFT_C_DEFINED
#define OBJREC_SERVERSIFT_C_DEFINED

#include <signal.h>
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
#include "SIFT/ScaleSpace.H"
#include "SIFT/VisualObject.H"
#include "SIFT/Keypoint.H"
#include "SIFT/VisualObjectDB.H"

#include "NeovisionII/nv2_common.h"
#include "NeovisionII/nv2_label_server.h"

ModelManager *mgr;
XWinManaged *xwin;
VisualObjectDB vdb;
bool debug = 0;
bool terminate = false;

#define USECOLOR false

std::string matchObject(Image<PixRGB<byte> > &ima);
struct nv2_label_server* labelServer;

void terminateProc(int s)
{
  LINFO("Ending application\n");
  terminate = true;
  nv2_label_server_destroy(labelServer);
  exit(0);
}

int main(const int argc, const char **argv)
{

  MYLOGVERB = LOG_INFO;
  mgr = new ModelManager("Test ObjRec");

  if (mgr->parseCommandLine(
        (const int)argc, (const char**)argv, "<vdb file> <server ip>", 2, 2) == false)
    return 1;

  mgr->start();

  // catch signals and redirect them to terminate for clean exit:
  signal(SIGHUP, terminateProc); signal(SIGINT, terminateProc);
  signal(SIGQUIT, terminateProc); signal(SIGTERM, terminateProc);
  signal(SIGALRM, terminateProc);

  //get command line options
  const char *vdbFile = mgr->getExtraArg(0).c_str();
  const char *server_ip = mgr->getExtraArg(1).c_str();
  bool train = false;

  LINFO("Loading db from %s\n", vdbFile);
  //vdb.loadFrom(std::string(vdbFile));

  xwin  = new XWinManaged(Dims(256,256),
      -1, -1, "ILab Robot Head Demo");


   labelServer =
    nv2_label_server_create(9930,
        server_ip,
        9931);

  nv2_label_server_set_verbosity(labelServer,1); //allow warnings


  int send_interval = 1;

  while(!terminate)
  {

    Point2D clickLoc = xwin->getLastMouseClick();
    if (clickLoc.isValid())
      train = !train;

    struct nv2_image_patch p;
    const enum nv2_image_patch_result res =
      nv2_label_server_get_current_patch(labelServer, &p);

    std::string objName;
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
      Image<PixRGB<byte> > img(p.width, p.height, NO_INIT);
      memcpy(img.getArrayPtr(), p.data, p.width*p.height*3);

      Image<PixRGB<byte> > inputImg = rescale(img, 256, 256);

      std::string objName = matchObject(inputImg);

      Image<PixRGB<byte> > disp(320, 240, ZEROS);

      xwin->drawImage(inputImg);

      if (objName == "nomatch")
      {
        if (train)
        {
          printf("Is this %s\n", objName.c_str());
          std::string tmp;
          std::getline(std::cin, tmp);
          if (tmp == "exit") break;
          if (tmp == "no")
          {
            printf("Can you tell me what this is?\n");
            std::getline(std::cin, objName);

            rutz::shared_ptr<VisualObject>
              vo(new VisualObject(objName.c_str(), "NULL", inputImg,
                    Point2D(-1,-1),
                    std::vector<double>(),
                    std::vector< rutz::shared_ptr<Keypoint> >(),
                    USECOLOR));
            vdb.addObject(vo);
            vdb.saveTo(vdbFile);
          }
        }
      } else {
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
            "auxiliary information");

        if (l.patch_id % send_interval == 0)
        {
          nv2_label_server_send_label(labelServer, &l);

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

  }
  nv2_label_server_destroy(labelServer);

}

std::string matchObject(Image<PixRGB<byte> > &ima)
{
  //find object in the database
  std::vector< rutz::shared_ptr<VisualObjectMatch> > matches;
  rutz::shared_ptr<VisualObject>
    vo(new VisualObject("PIC", "PIC", ima,
                        Point2D(-1,-1),
                        std::vector<double>(),
                        std::vector< rutz::shared_ptr<Keypoint> >(),
                        USECOLOR));

  const uint nmatches = vdb.getObjectMatches(vo, matches, VOMA_SIMPLE,
      5U, //max objs to return
      0.5F, //keypoint distance score default 0.5F
      0.5F, //affine distance score default 0.5F
      1.0F, //minscore  default 1.0F
      3U, //min # of keypoint match
      6U, //keypoint selection thershold
      false //sort by preattentive
      );

  LINFO("Found %i", nmatches);
  float score = 0, avgScore = 0, affineAvgDist = 0;
  int nkeyp = 0;
  int objId = -1;
  if (nmatches > 0 ){
    rutz::shared_ptr<VisualObject> obj; //so we will have a ref to the last matches obj
    rutz::shared_ptr<VisualObjectMatch> vom;
    //for(unsigned int i=0; i< nmatches; i++){
    for(unsigned int i=0; i< 1; i++){
      vom = matches[i];
      obj = vom->getVoTest();
      score = vom->getScore();
      nkeyp = vom->size();
      avgScore = vom->getKeypointAvgDist();
      affineAvgDist = vom->getAffineAvgDist();

      objId = atoi(obj->getName().c_str()+3);

      return obj->getName();
      LINFO("### Object match with '%s' score=%f ID:%i",
          obj->getName().c_str(), vom->getScore(), objId);

      //calculate the actual distance (location of keypoints) between
      //keypoints. If the same patch was found, then the distance should
      //be close to 0
      double dist = 0;
      for (int keyp=0; keyp<nkeyp; keyp++){
        const KeypointMatch kpm = vom->getKeypointMatch(keyp);

        float refX = kpm.refkp->getX();
        float refY = kpm.refkp->getY();

        float tstX = kpm.tstkp->getX();
        float tstY = kpm.tstkp->getY();
        dist += (refX-tstX) * (refX-tstX);
        dist += (refY-tstY) * (refY-tstY);
      }

   //   printf("%i:%s %i %f %i %f %f %f\n", objNum, obj->getName().c_str(),
   //       nmatches, score, nkeyp, avgScore, affineAvgDist, sqrt(dist));

      //analizeImage();
    }

  }

  return std::string("nomatch");
}


// ######################################################################
/* So things look consistent in everyone's emacs... */
/* Local Variables: */
/* indent-tabs-mode: nil */
/* c-file-style: "linux" */
/* End: */

#endif
