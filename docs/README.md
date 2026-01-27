# 실업급여 계산기 - 웹 버전

브라우저에서 바로 실행되는 실업급여 계산기입니다. 별도의 서버나 설치 없이 사용할 수 있습니다.

## 🚀 빠른 시작

### 방법 1: 로컬에서 실행

```bash
# 프로젝트 web 디렉토리로 이동
cd /Users/hyebin/Documents/DEV_PROJECT/calculator-collection/web

# 간단한 HTTP 서버 실행 (Python 사용)
python3 -m http.server 8000

# 브라우저에서 열기
open http://localhost:8000
```

### 방법 2: 파일로 직접 열기

```bash
# macOS
open /Users/hyebin/Documents/DEV_PROJECT/calculator-collection/web/index.html

# 또는 Finder에서 index.html을 더블클릭
```

## 📦 파일 구조

```
web/
├── index.html          # 메인 HTML (UI 구조)
├── styles.css          # 스타일시트 (디자인)
├── calculator.js       # 계산 로직 (JavaScript)
└── README.md          # 이 파일
```

## ✨ 주요 기능

### 3가지 근로자 유형 지원

1. **일반 근로자**
   - 생년월일, 장애인 여부
   - 고용보험 가입 시작/종료일
   - 최근 3개월 월급

2. **일용근로자**
   - 생년월일, 장애인 여부
   - 가입 기간 (년/월)
   - 마지막 근무일
   - 최근 3개월 일급 및 근무일수

3. **자영업자**
   - 가입 시작/종료일
   - 기준보수 등급 (1-7등급)

### 계산 결과

- **1일 구직급여일액**: 하루에 받을 수 있는 금액
- **예상 지급일수**: 120일 ~ 270일
- **총 예상수급액**: 전체 수급 금액

## 🎨 디자인 특징

- 📱 **반응형 디자인**: 모바일, 태블릿, 데스크톱 모두 지원
- 🎯 **직관적인 탭 인터페이스**: 근로자 유형별 쉬운 전환
- 💎 **모던한 UI**: 그라데이션과 부드러운 애니메이션
- ✅ **실시간 검증**: 입력 필드 자동 검증

## 📊 계산 기준

### 기본 규정
- **급여율**: 일 평균 임금의 60% (2019년 10월 1일 이후)
- **상한액**: 66,000원/일
- **하한액**: 최저임금(9,860원/시간) × 8시간 × 80% = 63,104원/일
- **수급 자격**: 고용보험 가입기간 180일 이상 (약 6개월)

### 지급일수 결정 기준

| 가입기간 | 30세 미만 | 30-50세 | 50세 이상/장애인 |
|----------|-----------|---------|------------------|
| 1년 미만 | 120일 | 120일 | 120일 |
| 1-3년 | 120일 | 150일 | 180일 |
| 3-5년 | 150일 | 180일 | 210일 |
| 5-10년 | 180일 | 210일 | 240일 |
| 10년 이상 | 210일 | 240일 | 270일 |

## 🌐 배포 방법

### GitHub Pages

```bash
# 1. GitHub 저장소로 푸시
git add web/
git commit -m "Add web version of unemployment calculator"
git push origin main

# 2. GitHub 저장소 설정
# - Settings > Pages
# - Source: Deploy from a branch
# - Branch: main
# - Folder: /web
# - Save

# 3. URL로 접속
# https://[username].github.io/calculator-collection/
```

### Netlify

```bash
# 1. Netlify 계정 생성 후 로그인
# 2. "New site from Git" 클릭
# 3. GitHub 저장소 연결
# 4. Build settings:
#    - Base directory: web
#    - Publish directory: .
# 5. Deploy!
```

### Vercel

```bash
# 1. Vercel CLI 설치
npm i -g vercel

# 2. 배포
cd web
vercel

# 3. 프로덕션 배포
vercel --prod
```

## 🔧 커스터마이징

### 색상 변경

`styles.css` 파일의 `:root` 섹션에서 색상을 변경할 수 있습니다:

```css
:root {
    --primary-color: #0066cc;      /* 메인 색상 */
    --primary-hover: #0052a3;      /* 호버 색상 */
    --success-color: #28a745;      /* 성공 색상 */
    --light-bg: #f8f9fa;           /* 배경 색상 */
}
```

### 상수 값 변경

`calculator.js` 파일의 `CONSTANTS` 객체에서 계산 기준을 변경할 수 있습니다:

```javascript
const CONSTANTS = {
    BENEFIT_RATE: 0.6,           // 급여율
    UPPER_LIMIT: 66000,          // 상한액
    MINIMUM_WAGE: 9860,          // 최저임금
    MINIMUM_INSURANCE_MONTHS: 6  // 최소 가입기간
};
```

## 📱 사용 예시

### 일반 근로자 계산

1. "일반 근로자" 탭 클릭
2. 생년월일 입력: `900101`
3. 가입 시작일: `2020-01-01`
4. 가입 종료일: `2024-01-01`
5. 최근 3개월 월급 입력: 각 `3000000`원
6. "계산하기" 클릭

**결과 예시:**
- 1일 구직급여일액: 60,000원
- 예상 지급일수: 210일
- 총 예상수급액: 12,600,000원

## ⚠️ 주의사항

- 이 계산기는 **모의 계산**을 위한 도구입니다
- 실제 수급액은 고용센터의 정확한 심사를 통해 결정됩니다
- 법률 및 정책 변경에 따라 계산 방식이 달라질 수 있습니다
- 정확한 수급액은 [고용보험 홈페이지](https://www.ei.go.kr)에서 확인하세요

## 🐛 알려진 제한사항

- 생년월일은 YYMMDD 형식만 지원 (6자리)
- 2019년 10월 1일 이전 규정 미지원 (급여율 50%)
- 월 단위 날짜 계산 사용 (일 단위보다 덜 정확)

## 🔄 버전 히스토리

### v1.0.0 (2026-01-27)
- 첫 번째 웹 버전 릴리스
- 3가지 근로자 유형 지원
- 반응형 디자인 구현
- 실시간 계산 기능

## 📚 참고 자료

- [고용보험 홈페이지](https://www.ei.go.kr)
- [실업급여 모의계산](https://eiac.ei.go.kr/ei/m/pf/MOW-PF-00-180-C.html)
- [고용보험법](https://www.law.go.kr)

## 🤝 기여

버그 리포트나 기능 제안은 이슈로 등록해주세요.

## 📄 라이선스

MIT License

---

**Made with ❤️ using Vanilla JavaScript**
