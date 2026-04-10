#include <iostream>
#include <cmath>

using namespace std;

struct Vec3
{
    double x, y, z; // 좌표값

    Vec3() : x(0), y(0), z(0) {}                             // 기본 생성자
    Vec3(double x, double y, double z) : x(x), y(y), z(z) {} // 값 초기화 생성자

    Vec3 operator+(const Vec3 &v) const // 벡터 덧셈
    {
        return Vec3(x + v.x, y + v.y, z + v.z); // 성분별 더하기
    }

    Vec3 operator-(const Vec3 &v) const // 벡터 뺄셈
    {
        return Vec3(x - v.x, y - v.y, z - v.z); // 성분별 빼기
    }

    Vec3 operator*(double s) const // 스칼라 곱
    {
        return Vec3(x * s, y * s, z * s); // 각 성분에 스칼라 곱
    }
};

int main()
{
    Vec3 A(0, 0, 0);
    Vec3 B(1, 0, 0);
    Vec3 C(0, 1, 0);

    Vec3 P1(0.3, 0.3, 2);
    Vec3 P2(0.3, 0.3, -2);

    Vec3 D = P2 - P1;

    // cross(B-A, C-A)
    Vec3 BA = B - A;
    Vec3 CA = C - A;
    Vec3 normal(
        BA.y * CA.z - BA.z * CA.y,
        BA.z * CA.x - BA.x * CA.z,
        BA.x * CA.y - BA.y * CA.x);

    // dot(D, normal)
    // denom 은 분모, D * n = 0이면 평행, 아니면 직선이 뚫고 지나감

    double denom = D.x * normal.x + D.y * normal.y + D.z * normal.z;

    if (fabs(denom) < 1e-9) // 1e-9 == 0으로 판단
    {
        cout << "직선이 평면과 평행합니다.\n";
        return 0;
    }

    Vec3 AP1 = A - P1;
    // numerator : 분자
    double numerator = AP1.x * normal.x + AP1.y * normal.y + AP1.z * normal.z;

    double t = numerator / denom;

    Vec3 Q = P1 + D * t;

    cout << "교점 Q: (" << Q.x << ", " << Q.y << ", " << Q.z << ")\n";

    if (t < 0.0 || t > 1.0)
        cout << "교점이 선분 밖에 있습니다.\n";
    else
        cout << "교점이 선분 위에 있습니다.\n";

    // barycentric
    Vec3 v0 = B - A;
    Vec3 v1 = C - A;
    Vec3 v2 = Q - A;

    double d00 = v0.x * v0.x + v0.y * v0.y + v0.z * v0.z;
    double d01 = v0.x * v1.x + v0.y * v1.y + v0.z * v1.z;
    double d11 = v1.x * v1.x + v1.y * v1.y + v1.z * v1.z;
    double d20 = v2.x * v0.x + v2.y * v0.y + v2.z * v0.z;
    double d21 = v2.x * v1.x + v2.y * v1.y + v2.z * v1.z;

    double denom2 = d00 * d11 - d01 * d01;

    if (denom2 == 0)
    {
        cout << "삼각형이 퇴화되었습니다.\n";
        return 0;
    }

    double v = (d11 * d20 - d01 * d21) / denom2;
    double w = (d00 * d21 - d01 * d20) / denom2;
    double u = 1.0 - v - w;

    if (u >= 0 && v >= 0 && w >= 0)
        cout << "Q는 삼각형 내부에 있습니다.\n";
    else
        cout << "Q는 삼각형 외부에 있습니다.\n";

    return 0;
}