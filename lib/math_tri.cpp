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

// 내적
double dot(const Vec3 &a, const Vec3 &b) // 내적 계산
{
    return a.x * b.x + a.y * b.y + a.z * b.z; // x*x + y*y + z*z
}

// 외적
Vec3 cross(const Vec3 &a, const Vec3 &b) // 외적 계산
{
    return Vec3(
        a.y * b.z - a.z * b.y,  // y*z - z*y
        a.z * b.x - a.x * b.z,  // z*x - x*z
        a.x * b.y - a.y * b.x); // x*y - y*x
}

// ===============================
// 삼각형 내부 판정 (Barycentric)
// ===============================
bool isInsideTriangle(const Vec3 &A, const Vec3 &B, const Vec3 &C, const Vec3 &P) // 점 P가 삼각형 내부인지 검사
{
    Vec3 v0 = B - A; // AB 벡터
    Vec3 v1 = C - A; // AC 벡터
    Vec3 v2 = P - A; // AP 벡터

    double d00 = dot(v0, v0); // v0의 길이 제곱 (AB 벡터의 길이^2)
    double d01 = dot(v0, v1); // v0와 v1의 내적 (두 변 사이의 각도/관계)
    double d11 = dot(v1, v1); // v1의 길이 제곱
    double d20 = dot(v2, v0); // 점 P 벡터(v2)를 v0 방향으로 투영한 값
    double d21 = dot(v2, v1); // 점 P 벡터(v2)를 v1 방향으로 투영한 값

    double denom = d00 * d11 - d01 * d01; // 분모
    if (denom == 0)                       // 삼각형이 퇴화된 경우
        return false;

    double v = (d11 * d20 - d01 * d21) / denom; // barycentric 좌표
    double w = (d00 * d21 - d01 * d20) / denom; // barycentric 좌표
    double u = 1.0 - v - w;                     // barycentric 좌표

    return (u >= 0 && v >= 0 && w >= 0); // 모두 0 이상이면 내부
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
    double &t) // 직선과 평면 교점 계산
{
    Vec3 D = P2 - P1;                  // 방향 벡터
    Vec3 normal = cross(B - A, C - A); // 평면 법선

    double denom = dot(D, normal); // 분모 (평행 여부 판단)

    if (fabs(denom) < 1e-9) // 거의 0이면 평행
    {
        cout << "직선이 평면과 평행합니다.\n"; // 디버그 출력
        return false;
    }

    t = dot(A - P1, normal) / denom; // 교점까지 비율

    Q = P1 + D * t; // 교점 계산

    return true; // 교점 존재
}

// ===============================
// 메인
// ===============================
int main() // 프로그램 시작
{

    // 삼각형
    Vec3 A(0, 0, 0); // 삼각형 꼭짓점 A
    Vec3 B(1, 0, 0); // 삼각형 꼭짓점 B
    Vec3 C(0, 1, 0); // 삼각형 꼭짓점 C

    // 직선 (두 점)
    Vec3 P1(0.3, 0.3, 2);  // 직선 시작점
    Vec3 P2(0.3, 0.3, -2); // 직선 끝점

    Vec3 Q;   // 교점
    double t; // 파라미터 값

    if (!intersectLinePlane(P1, P2, A, B, C, Q, t)) // 교점 없으면 종료
    {
        return 0;
    }

    cout << "교점 Q: (" << Q.x << ", " << Q.y << ", " << Q.z << ")\n"; // 교점 출력

    // 선분 범위 체크(t:가중치)
    if (t < 0.0 || t > 1.0) // 선분 범위 체크
    {
        cout << "교점이 선분 밖에 있습니다 (무한 직선 상에서는 존재).\n"; // 교점이 선분 밖임
    }
    else
    {
        cout << "교점이 선분 위에 있습니다.\n"; // 교점이 선분 위임
    }

    // 삼각형 내부 판정
    if (isInsideTriangle(A, B, C, Q)) // 내부 여부 검사
    {
        cout << "Q는 삼각형 내부에 있습니다.\n"; // 내부임
    }
    else
    {
        cout << "Q는 삼각형 외부에 있습니다.\n"; // 외부임
    }

    return 0; // 정상 종료
}