#include <iostream>
#include <cmath>

using namespace std;

struct Vec3
{
    double x, y, z;

    Vec3() : x(0), y(0), z(0) {}
    Vec3(double x, double y, double z) : x(x), y(y), z(z) {}

    Vec3 operator+(const Vec3 &v) const
    {
        return Vec3(x + v.x, y + v.y, z + v.z);
    }

    Vec3 operator-(const Vec3 &v) const
    {
        return Vec3(x - v.x, y - v.y, z - v.z);
    }

    Vec3 operator*(double s) const
    {
        return Vec3(x * s, y * s, z * s);
    }
};

// 내적
double dot(const Vec3 &a, const Vec3 &b)
{
    return a.x * b.x + a.y * b.y + a.z * b.z;
}

// 외적
Vec3 cross(const Vec3 &a, const Vec3 &b)
{
    return Vec3(
        a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x);
}

// ===============================
// 삼각형 내부 판정 (Barycentric)
// ===============================
bool isInsideTriangle(const Vec3 &A, const Vec3 &B, const Vec3 &C, const Vec3 &P)
{
    Vec3 v0 = B - A;
    Vec3 v1 = C - A;
    Vec3 v2 = P - A;

    double d00 = dot(v0, v0);
    double d01 = dot(v0, v1);
    double d11 = dot(v1, v1);
    double d20 = dot(v2, v0);
    double d21 = dot(v2, v1);

    double denom = d00 * d11 - d01 * d01;
    if (denom == 0)
        return false;

    double v = (d11 * d20 - d01 * d21) / denom;
    double w = (d00 * d21 - d01 * d20) / denom;
    double u = 1.0 - v - w;

    return (u >= 0 && v >= 0 && w >= 0);
}

// ===============================
// 직선-평면 교점 계산
// ===============================
bool intersectLinePlane(
    const Vec3 &P1,
    const Vec3 &P2,
    const Vec3 &A,
    const Vec3 &B,
    const Vec3 &C,
    Vec3 &Q,
    double &t)
{
    Vec3 D = P2 - P1;                  // 직선 방향
    Vec3 normal = cross(B - A, C - A); // 평면 법선

    double denom = dot(D, normal);

    if (fabs(denom) < 1e-9)
    {
        cout << "직선이 평면과 평행합니다.\n";
        return false;
    }

    t = dot(A - P1, normal) / denom;

    Q = P1 + D * t;

    return true;
}

// ===============================
// 메인
// ===============================
int main()
{

    // 삼각형
    Vec3 A(0, 0, 0);
    Vec3 B(1, 0, 0);
    Vec3 C(0, 1, 0);

    // 직선 (두 점)
    Vec3 P1(0.3, 0.3, 2);
    Vec3 P2(0.3, 0.3, -2);

    Vec3 Q;
    double t;

    if (!intersectLinePlane(P1, P2, A, B, C, Q, t))
    {
        return 0;
    }

    cout << "교점 Q: (" << Q.x << ", " << Q.y << ", " << Q.z << ")\n";

    // 선분 범위 체크
    if (t < 0.0 || t > 1.0)
    {
        cout << "교점이 선분 밖에 있습니다 (무한 직선 상에서는 존재).\n";
    }
    else
    {
        cout << "교점이 선분 위에 있습니다.\n";
    }

    // 삼각형 내부 판정
    if (isInsideTriangle(A, B, C, Q))
    {
        cout << "Q는 삼각형 내부에 있습니다.\n";
    }
    else
    {
        cout << "Q는 삼각형 외부에 있습니다.\n";
    }

    return 0;
}