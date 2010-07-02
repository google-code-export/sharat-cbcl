/*!@file NeovisionII/Nv2LabelReader.C */

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
// Primary maintainer for this file: Rob Peters <rjpeters at usc dot edu>
// $HeadURL: svn://iLab.usc.edu/trunk/saliency/src/NeovisionII/Nv2LabelReader.C $
// $Id: Nv2LabelReader.C 9372 2007-08-08 03:51:04Z rjpeters $
//

#ifndef NEOVISIONII_NV2LABELREADER_C_DEFINED
#define NEOVISIONII_NV2LABELREADER_C_DEFINED

#include "NeovisionII/Nv2LabelReader.H"

#include "Image/CutPaste.H"
#include "Image/DrawOps.H"
#include "NeovisionII/nv2_label_reader.h"
#include "Util/StringConversions.H"
#include "Util/StringUtil.H"
#include "Util/sformat.H"

// ######################################################################
Nv2LabelReader::Nv2LabelReader(const PixRGB<byte> color_,
                               const int label_reader_port,
                               const std::string& remote_patch_reader)
  :
  reader(),
  color(color_),
  lastConfidence()
{
  std::vector<std::string> parts;
  split(remote_patch_reader, ":", std::back_inserter(parts));
  if (parts.size() != 2 && parts.size() != 3)
    LFATAL("couldn't parse addr:port[:pixtype] from '%s'",
           remote_patch_reader.c_str());

  const std::string remote_patch_reader_addr = parts[0];
  const int remote_patch_reader_port = fromStr<int>(parts[1]);

  this->pixtype = NV2_PIXEL_TYPE_GRAY8;
  if (parts.size() >= 3)
    {
      if (parts[2].compare("gray8") == 0)
        this->pixtype = NV2_PIXEL_TYPE_GRAY8;
      else if (parts[2].compare("rgb24") == 0)
        this->pixtype = NV2_PIXEL_TYPE_RGB24;
      else
        LFATAL("invalid pixel type %s (expected gray8 or rgb24",
               parts[2].c_str());
    }

  reader = nv2_label_reader_create(label_reader_port,
                                   remote_patch_reader_addr.c_str(),
                                   remote_patch_reader_port);

  LINFO("label reader at %s:%d, "
        "listening for labels on port %d",
        remote_patch_reader_addr.c_str(),
        remote_patch_reader_port,
        label_reader_port);
}

// ######################################################################
Nv2LabelReader::~Nv2LabelReader()
{
  nv2_label_reader_destroy(reader);
}

// ######################################################################
void Nv2LabelReader::sendPatch(const uint32_t id,
                               const Image<PixRGB<byte> >& fullimg,
                               const Rectangle& foa,
                               const Image<PixRGB<byte> >& foapatch,
                               const rutz::time& qtime,
                               bool is_training_image,
                               const std::string& training_label,
                               const std::string& remote_command)
{
  {
    const size_t npix = foapatch.getSize();

    nv2_image_patch patch;
    patch.protocol_version = NV2_PATCH_PROTOCOL_VERSION;
    patch.width = foapatch.getWidth();
    patch.height = foapatch.getHeight();
    patch.id = id;
    patch.is_training_image = is_training_image ? 1 : 0;
    patch.type = this->pixtype;
    nv2_image_patch_set_training_label(&patch, training_label.c_str());
    nv2_image_patch_set_remote_command(&patch, remote_command.c_str());

    switch (this->pixtype)
      {
      case NV2_PIXEL_TYPE_NONE:
        patch.data = 0;
        break;

      case NV2_PIXEL_TYPE_GRAY8:
        {
          patch.data = (unsigned char*) malloc(npix * sizeof(byte));
          if (patch.data == 0)
            LFATAL("malloc() failed");

          const Image<PixRGB<byte> >::const_iterator foaptr =
            foapatch.begin();

          for (size_t i = 0; i < npix; ++i)
            patch.data[i] = foaptr[i].luminance();
        }
        break;

      case NV2_PIXEL_TYPE_RGB24:
        {
          patch.data = (unsigned char*) malloc(3 * npix * sizeof(byte));
          if (patch.data == 0)
            LFATAL("malloc() failed");

          memcpy(&patch.data[0], foapatch.getArrayPtr(),
                 3 * npix * sizeof(byte));
        }
        break;
      }

    nv2_label_reader_send_patch(reader, &patch);
  }

  PendingImage qimg;
  qimg.fullimg = fullimg;
  qimg.foa = foa;
  qimg.patch_id = id;
  qimg.qtime = rutz::time::wall_clock_now();

  imgq.push_back(qimg);

  // if the queue gets too large, just drop some old frames so that
  // we don't allow unbounded memory usage
  while (imgq.size() > 60)
    {
      imgq.pop_front();
    }
}

// ######################################################################
Nv2LabelReader::LabeledImage
Nv2LabelReader::getNextLabeledImage(bool ignore_nomatch,
                                    const size_t text_length)
{
  LabeledImage result;

  if (imgq.size() == 0)
    return result; // with a still-empty image

  struct nv2_patch_label label;
  const int gotit =
    nv2_label_reader_get_current_label(reader, &label);

  if (!gotit)
    return result; // with a still-empty image

  // else ...

  lastConfidence.atomic_set(label.confidence);

  result.ident = label.source;
  result.label = label.name;

  while (imgq.size() > 0 && imgq.front().patch_id < label.patch_id)
    // forget about patches that have been skipped by the label
    // server:
    imgq.pop_front();

  if (imgq.size() == 0 || imgq.front().patch_id > label.patch_id)
    return result; // with a still-empty image

  ASSERT(imgq.size() > 0 && imgq.front().patch_id == label.patch_id);

  PendingImage qimg = imgq.front();
  imgq.pop_front();

  if (ignore_nomatch &&
      (strncmp(label.name, "nomatch", 7) == 0 ||
       strncmp(label.name, "none", 4) == 0))
    return result; // with a still-empty image

  LINFO("label.name = '%s'", label.name);

  const rutz::time now = rutz::time::wall_clock_now();

  times.push_back(now);

  const double fps =
    times.size() >= 2
    ? (times.size() - 1) / (times.back() - times.front()).sec()
    : 0.0;

  if (times.size() > 2 && (times.back() - times.front()).sec() > 3.0)
    times.pop_front();

  drawRectSquareCorners(qimg.fullimg, qimg.foa, this->color, 3);

  const std::string lines[3] =
    {
      sformat("[c=%4.2f] %s",
              double(label.confidence) / double(NV2_MAX_LABEL_CONFIDENCE),
              label.name),
      sformat("%s", label.extra_info),
      sformat("%s: lag %06.3fs #%06u [%5.2ffps]",
              label.source,
              (now - qimg.qtime).sec(),
              (unsigned int) label.patch_id,
              fps)
    };

  const Image<PixRGB<byte> > textarea =
    makeMultilineTextBox(qimg.fullimg.getWidth(), &lines[0], 3,
                         this->color, PixRGB<byte>(0,0,0),
                         text_length);

  result.img = concatY(qimg.fullimg, textarea);
  return result;
}

// ######################################################################
double Nv2LabelReader::getLastConfidence() const
{
  return (double(lastConfidence.atomic_get())
          / double(NV2_MAX_LABEL_CONFIDENCE));
}

// ######################################################################
/* So things look consistent in everyone's emacs... */
/* Local Variables: */
/* mode: c++ */
/* indent-tabs-mode: nil */
/* End: */

#endif // NEOVISIONII_NV2LABELREADER_C_DEFINED
