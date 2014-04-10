//
//  L1SphericalGeometry.m
//  Writer on the Train
//
//  Created by Joe Zuntz on 05/04/2014.
//  Copyright (c) 2014 Joe Zuntz. All rights reserved.
//

#import "L1SphericalGeometry.h"
#import <CoreLocation/CoreLocation.h>


void dgetrf_(int* M, int *N, double* A, int* lda, int* IPIV, int* INFO);
void dgetri_(int* N, double* A, int* lda, int* IPIV, double* WORK, int* lwork, int* INFO);


void lapack_inverse(double* A, int N)
{
    int IPIV[N+1];
    int LWORK = N*N;
    double WORK[LWORK];
    int INFO;
    
    dgetrf_(&N,&N,A,&N,IPIV,&INFO);
    dgetri_(&N,A,&N,IPIV,WORK,&LWORK,&INFO);
    
}


void matrix_inverse(int n, double M[n][n]){
    int p=0;
    double A[n*n];
    for (int i=0; i<n; i++){
        for (int j=0; j<n; j++){
            A[p++] = M[i][j];
        }
    }
    
    lapack_inverse(A,n);
    p=0;
    for (int i=0; i<n; i++){
        for (int j=0; j<n; j++){
            M[i][j] = A[p++];
        }
    }
    
}

int levi_civita(int i, int j, int k){
    if (i==j || i==k || j==k) return 0;
    if ((i==1 && j==2 && k==3)|| (i==2 && j==3 && k==1) || (i==3 && j==1 && k==2)) return 1;
    return -1;
}

void find_rotated_point(double v0[3], double v1[3], double theta, double v2[3])
{
    assert(NO); // THIS DOES NOT WORK
//    double x[3];
    double M[3][3];
    double b[3];
    for (int i=0; i<3; i++) b[i] = sin(theta) * v0[i];
    for (int i=0; i<3; i++){
        for (int k=0; k<3; k++){
            M[i][k] = 0.0;
            for (int j=0; j<3; j++) M[i][k] += levi_civita(i,j,k) * v1[j];
        }
    }
    matrix_inverse(3, M);
    for (int i=0; i<3; i++){
        v2[i] = 0.0;
        for (int k=0; k<3; k++){
            v2[k] += M[i][k]*b[k];
        }
    }
    normalize_vector(v2);
}
#define DEGRA 0.01745329251
#define RADEG 57.2957795131

void coordinate_to_cartesian(CLLocationCoordinate2D p, double v[3]){
    
    p.latitude *= DEGRA;
    p.longitude *= DEGRA;
    double cosb = cos(p.latitude);
    v[0] = cos(p.longitude)*cosb;
    v[1] = sin(p.longitude)*cosb;
    v[2] = sin(p.latitude);
}





void cartesian_to_coordinate(double v[3], CLLocationCoordinate2D * p)
{
    double X = v[0];
    double Y = v[1];
    double Z = v[2];
    double  R = sqrt(X*X+Y*Y);
    double A, B;
    if (R==0){
        A = 0.0;
    }
    else {
        A = atan2(Y,X);
    }
    
    if (Z==0.0) B=0.0;
    else B=atan2(Z,R);
    p->longitude = A*RADEG;
    p->latitude = B*RADEG;
}

CLLocationCoordinate2D find_rotated_coordinate(double v0[3], double v1[3], double theta)
{
    double v2[3];
    find_rotated_point(v0, v1, theta, v2);
    CLLocationCoordinate2D point;
    cartesian_to_coordinate(v2, &point);
    return point;
}

double dot_product(double x[3], double y[3])
{
    return x[0]*y[0] + x[1]*y[1] + x[2]*y[2];
}

void cross_product(double x[3], double y[3], double z[3])
{
    z[0] = x[1]*y[2]-x[2]*y[1];
    z[1] = x[0]*y[2]-x[2]*y[0];
    z[2] = x[0]*y[1]-x[1]*y[0];
}

void normalize_vector(double v[3])
{
    double r = sqrt(v[0]*v[0]+v[1]*v[1]+v[2]*v[2]);
    v[0]/=r;
    v[1]/=r;
    v[2]/=r;
    
}

double coordinate_dot_cross_product(CLLocationCoordinate2D x, CLLocationCoordinate2D y, double z[3])
{
    double vx[3];
    double vy[3];
    coordinate_to_cartesian(x, vx);
    coordinate_to_cartesian(y, vy);
    cross_product(vx, vy, z);
    return dot_product(vx,vy);
}

