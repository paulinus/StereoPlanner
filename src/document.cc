#include "document.h"


/* Author: Paul Brouke
   Calculate the line segment PaPb that is the shortest route between
   two lines P1P2 and P3P4. Calculate also the values of mua and mub where
      Pa = P1 + mua (P2 - P1)
      Pb = P3 + mub (P4 - P3)
   Return FALSE if no solution exists.
*/
static int LineLineIntersect(const Vector3d &p1,
                             const Vector3d &p2,
                             const Vector3d &p3,
                             const Vector3d &p4,
                             Vector3d *pa,
                             Vector3d *pb,
                             double *mua,
                             double *mub) {
   const double EPS = 1e-8;
   Vector3d p13,p43,p21;
   double d1343,d4321,d1321,d4343,d2121;
   double numer,denom;

   p13[0] = p1[0] - p3[0];
   p13[1] = p1[1] - p3[1];
   p13[2] = p1[2] - p3[2];
   p43[0] = p4[0] - p3[0];
   p43[1] = p4[1] - p3[1];
   p43[2] = p4[2] - p3[2];
   if (fabs(p43[0])  < EPS && fabs(p43[1])  < EPS && fabs(p43[2])  < EPS)
      return(FALSE);
   p21[0] = p2[0] - p1[0];
   p21[1] = p2[1] - p1[1];
   p21[2] = p2[2] - p1[2];
   if (fabs(p21[0])  < EPS && fabs(p21[1])  < EPS && fabs(p21[2])  < EPS)
      return(FALSE);

   d1343 = p13[0] * p43[0] + p13[1] * p43[1] + p13[2] * p43[2];
   d4321 = p43[0] * p21[0] + p43[1] * p21[1] + p43[2] * p21[2];
   d1321 = p13[0] * p21[0] + p13[1] * p21[1] + p13[2] * p21[2];
   d4343 = p43[0] * p43[0] + p43[1] * p43[1] + p43[2] * p43[2];
   d2121 = p21[0] * p21[0] + p21[1] * p21[1] + p21[2] * p21[2];

   denom = d2121 * d4343 - d4321 * d4321;
   if (fabs(denom) < EPS)
      return(FALSE);
   numer = d1343 * d4321 - d1321 * d4343;

   *mua = numer / denom;
   *mub = (d1343 + d4321 * (*mua)) / d4343;

   *pa = p1 + *mua * p21;
   *pb = p3 + *mub * p43;

   return(TRUE);
}


SpDocument::SpDocument() {
  focal_length_ = 50;
  sensor_width_ = 36;
  sensor_height_ = 24;

  rig_interocular_ = .65;
  rig_position_ << 0, 0, -6;
  rig_pan_ = 0;
  rig_tilt_ = 0;
  rig_roll_ = 0;

  screen_width_ = 20;
  screen_height_ = 15;

  observer_interocular_ = 6.5;
  observer_position_ << 0, 0, -30;
  observer_pan_ = 0;
  observer_tilt_ = 0;
  observer_roll_ = 0;

  capture_geometry_ = CubeGeometry();
  UpdateEverything();
}

SpDocument::~SpDocument() {
}

void SpDocument::SetFocalLegth(double v) {
  if (focal_length_ != v) {
    focal_length_ = v;
    UpdateEverything();
  }
}

void SpDocument::SetSensorWidth(double v) {
  if (sensor_width_ != v) {
    sensor_width_ = v;
    UpdateEverything();
  }
}

void SpDocument::SetSensorHeight(double v) {
  if (sensor_height_ != v) {
    sensor_height_ = v;
    UpdateEverything();
  }
}

void SpDocument::UpdateEverything() {
  ProjectToSensor();
  SensorToScreen();
  Triangulate();
  emit DocumentChanged();
}

Vector3d SpDocument::CameraPosition(int i) {
  Vector3d shift((i==0?-1:1) * rig_interocular_ / 2, 0, 0);
  return rig_position_ + RigRotation() * shift;
}

void SpDocument::ProjectToSensor() {
  for (int i = 0; i < 2; ++i) {
    Vector3d pos = CameraPosition(i);
    Camera camera(focal_length_, sensor_width_, sensor_height_,
        pos, RigRotation());
    // TODO(pau): Test Project capture geometry.
    ProjectGeometry(capture_geometry_, camera, &sensor_geometry_[i]);
  }
}

void SpDocument::SensorToScreen() {
  for (int i = 0; i < 2; ++i) {
    // TODO(pau): Test scale geometry.
    ScaleGeometry(sensor_geometry_[i], screen_width_ / 2, screen_height_ / 2,
        1, &screen_geometry_[i]);
  }
}

Vector3d SpDocument::EyePosition(int i) {
  Vector3d shift((i==0?-1:1) * observer_interocular_ / 2, 0, 0);
  return observer_position_ 
    + ObserverRotation() * shift;
}


void SpDocument::Triangulate() {
  // TODO(pau): Test Triangulate.
  Vector3d left_eye = EyePosition(0);
  Vector3d right_eye = EyePosition(1);

  theater_geometry_.vertex_.resize(screen_geometry_[0].vertex_.size());
  for (unsigned int i = 0; i < theater_geometry_.vertex_.size(); i += 4) {
    Vector3d left_point(screen_geometry_[0].vertex_[i + 0],
        screen_geometry_[0].vertex_[i + 1],
        screen_geometry_[0].vertex_[i + 2]);
    left_point /= screen_geometry_[0].vertex_[i + 3];
    Vector3d right_point(screen_geometry_[1].vertex_[i + 0],
        screen_geometry_[1].vertex_[i + 1],
        screen_geometry_[1].vertex_[i + 2]);
    right_point /= screen_geometry_[1].vertex_[i + 3];

    Vector3d pa, pb;
    double mua, mub;
    LineLineIntersect(left_eye, left_point, right_eye, right_point,
        &pa, &pb, &mua, &mub);
    Vector3d intersection = (pa + pb) / 2;

    theater_geometry_.vertex_[i + 0] = intersection[0];
    theater_geometry_.vertex_[i + 1] = intersection[1];
    theater_geometry_.vertex_[i + 2] = intersection[2];
    theater_geometry_.vertex_[i + 3] = 1;
  }
  theater_geometry_.triangles_ = screen_geometry_[0].triangles_;
}
