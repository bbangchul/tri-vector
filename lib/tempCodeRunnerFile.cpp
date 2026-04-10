struct Vec3
// {
//     double x, y, z; // 좌표값

//     Vec3() : x(0), y(0), z(0) {}                             // 기본 생성자
//     Vec3(double x, double y, double z) : x(x), y(y), z(z) {} // 값 초기화 생성자

//     Vec3 operator+(const Vec3 &v) const // 벡터 덧셈
//     {
//         return Vec3(x + v.x, y + v.y, z + v.z); // 성분별 더하기
//     }

//     Vec3 operator-(const Vec3 &v) const // 벡터 뺄셈
//     {
//         return Vec3(x - v.x, y - v.y, z - v.z); // 성분별 빼기
//     }

//     Vec3 operator*(double s) const // 스칼라 곱
//     {
//         return Vec3(x * s, y * s, z * s); // 각 성분에 스칼라 곱
//     }
// };