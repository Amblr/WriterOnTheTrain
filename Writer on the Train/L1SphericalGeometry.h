//
//  L1SphericalGeometry.h
//  Writer on the Train
//
//  Created by Joe Zuntz on 05/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

void matrix_inverse(int n, double M[n][n]);
int levi_civita(int i, int j, int k);
void find_rotated_point(double v0[3], double v1[3], double theta, double v2[3]);
void coordinate_to_cartesian(CLLocationCoordinate2D p, double v[3]);
void cartesian_to_coordinate(double v[3], CLLocationCoordinate2D * p);
CLLocationCoordinate2D find_rotated_coordinate(double v0[3], double v1[3], double theta);
void normalize_vector(double v[3]);
double coordinate_dot_cross_product(CLLocationCoordinate2D x, CLLocationCoordinate2D y, double z[3]);
double dot_product(double x[3], double y[3]);
