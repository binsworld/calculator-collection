# 프로젝트 개발 히스토리

## 2026-01-27 (오후): 웹 버전 추가 구현

### 배경
- 사용자가 웹서비스를 원했으나, 초기에는 REPL(CLI) 버전으로 구현
- Mojo는 웹 프레임워크가 제한적이므로, JavaScript로 웹 버전 재구현 결정

### 구현 내용

#### 웹 버전 구조
```
web/
├── index.html       # UI 구조 (HTML5)
├── styles.css       # 반응형 디자인 (CSS3)
├── calculator.js    # 계산 로직 (Vanilla JS)
└── README.md        # 웹 버전 가이드
```

#### 주요 기능

##### 1. HTML (index.html)
- 3개 탭 구조: 일반 근로자, 일용근로자, 자영업자
- 각 탭별 맞춤형 입력 폼
- 결과 표시 영역
- 반응형 레이아웃

##### 2. CSS (styles.css)
- 모던한 그라데이션 디자인
- 반응형 레이아웃 (모바일, 태블릿, 데스크톱)
- 부드러운 애니메이션 효과
- 사용자 친화적 UI/UX

**주요 스타일:**
- Primary 색상: `#0066cc` (파란색)
- 그라데이션 헤더: `#667eea` → `#764ba2`
- 카드 레이아웃, 그림자 효과
- 호버 애니메이션

##### 3. JavaScript (calculator.js)
Mojo 코드를 JavaScript로 완전 포팅:

**유틸리티 함수:**
- `monthsBetweenDates()`: 날짜 간 개월수 계산
- `calculateAge()`: YYMMDD 형식 생년월일로 나이 계산
- `getPaymentDays()`: 나이/가입기간별 지급일수
- `applyBenefitRate()`: 급여율 60% 적용
- `applyBenefitLimits()`: 상한액/하한액 적용
- `formatCurrency()`: 천단위 콤마 포맷팅

**계산 함수:**
- `calculateRegularWorkerBenefit()`: 일반 근로자 계산
- `calculateDailyWorkerBenefit()`: 일용근로자 계산
- `calculateSelfEmployedBenefit()`: 자영업자 계산

**UI 함수:**
- `switchTab()`: 탭 전환
- `resetForm()`: 폼 초기화
- `displayResult()`: 결과 표시

#### 배포 옵션
- **GitHub Pages**: 무료 정적 호스팅
- **Netlify**: 자동 배포 지원
- **Vercel**: 빠른 글로벌 CDN
- **로컬 실행**: Python HTTP 서버

### 기술적 차이점

| 항목 | Mojo 버전 | 웹 버전 |
|------|-----------|---------|
| 언어 | Mojo | JavaScript |
| 실행 | CLI (터미널) | 브라우저 |
| 설치 | Mojo 필요 | 불필요 |
| 플랫폼 | macOS/Linux | 모든 브라우저 |
| UI | 텍스트 기반 | 그래픽 기반 |
| 배포 | 로컬만 | 웹 호스팅 가능 |

### 개선 사항
- 입력 검증 강화 (HTML5 validation)
- 실시간 계산 (폼 제출 시)
- 스크롤 애니메이션 (결과 표시 시)
- 모바일 최적화
- 접근성 향상

---

## 2026-01-27 (오전): 프로젝트 초기 설정 및 Mojo CLI 버전 구현

### 프로젝트 개요
- **목표**: Mojo 언어로 실업급여 계산기 허브 구현
- **인터페이스**: REPL (대화형) 방식
- **대상**: 대한민국 실업급여 계산 규정

### 구현 내용

#### 1. 프로젝트 구조 설정
```
calculator-collection/
├── src/
│   └── unemployment_calculator/
│       ├── __init__.mojo
│       ├── types.mojo
│       ├── utils.mojo
│       ├── calculator.mojo
│       └── main.mojo
├── tests/
├── README.md
├── HISTORY.md
└── .gitignore
```

#### 2. 구현된 모듈

##### types.mojo
- **Date**: 날짜 표현 구조체 (year, month, day)
- **RegularWorkerInput**: 일반 근로자 입력 데이터 구조체
  - 생년월일, 장애인 여부, 가입 시작/종료일, 최근 3개월 월급
- **DailyWorkerInput**: 일용근로자 입력 데이터 구조체
  - 생년월일, 장애인 여부, 가입 기간, 최근 3개월 일급 및 근무일수
- **SelfEmployedInput**: 자영업자 입력 데이터 구조체
  - 가입 시작/종료일, 기준보수 등급 (1-7등급)
- **UnemploymentBenefitResult**: 계산 결과 구조체
  - 일일 수급액, 지급일수, 총 수급액, 수급자격 여부, 오류 메시지

##### utils.mojo
유틸리티 함수들:
- `days_between_dates()`: 두 날짜 사이의 일수 계산
- `months_between_dates()`: 두 날짜 사이의 개월수 계산
- `calculate_age_from_birth_date()`: 생년월일로부터 나이 계산 (YYMMDD 형식)
- `get_payment_days_by_age_and_period()`: 나이와 가입기간에 따른 지급일수 반환
- `get_disability_payment_days()`: 장애인 지급일수 반환
- `calculate_daily_average_wage()`: 일 평균 임금 계산
- `apply_benefit_rate()`: 급여율 적용 (2019년 이후 60%, 이전 50%)
- `apply_benefit_limits()`: 상한액(66,000원), 하한액(최저임금 80%) 적용
- `validate_insurance_period()`: 가입기간 180일 이상 검증
- `parse_date_input()`: 날짜 문자열 파싱 (YYYY-MM-DD)

##### calculator.mojo
계산 로직 함수들:
- `calculate_regular_worker_benefit()`: 일반 근로자 실업급여 계산
  1. 가입기간 계산 및 검증
  2. 나이 계산
  3. 최근 3개월 평균 임금 계산
  4. 일 평균 임금 계산 (월 평균 / 30)
  5. 급여율 60% 적용
  6. 상한액/하한액 적용
  7. 지급일수 결정 (나이, 가입기간, 장애인 여부)
  8. 총 수급액 계산

- `calculate_daily_worker_benefit()`: 일용근로자 실업급여 계산
  1. 가입기간 계산 및 검증
  2. 나이 계산
  3. 최근 3개월 총 임금 및 근무일수 계산
  4. 일 평균 임금 계산
  5. 급여율 60% 적용
  6. 상한액/하한액 적용
  7. 지급일수 결정
  8. 총 수급액 계산

- `calculate_self_employed_benefit()`: 자영업자 실업급여 계산
  1. 가입기간 계산 및 검증
  2. 기준보수 등급별 월 기준보수 결정 (1등급: 100만원 ~ 7등급: 400만원)
  3. 일 평균 임금 계산
  4. 급여율 60% 적용
  5. 상한액/하한액 적용
  6. 지급일수 결정 (50세 이상 기준 적용)
  7. 총 수급액 계산

##### main.mojo
REPL 인터페이스:
- `print_welcome_message()`: 환영 메시지 및 메뉴 출력
- `get_user_choice()`: 사용자 선택 입력
- `get_string_input()`, `get_float_input()`, `get_int_input()`, `get_bool_input()`: 다양한 타입 입력 함수
- `handle_regular_worker()`: 일반 근로자 입력 및 계산 처리
- `handle_daily_worker()`: 일용 근로자 입력 및 계산 처리
- `handle_self_employed()`: 자영업자 입력 및 계산 처리
- `main()`: 메인 REPL 루프

#### 3. 지급일수 결정 기준 (한국 고용보험법 기준)

| 가입기간 | 30세 미만 | 30-50세 미만 | 50세 이상/장애인 |
|----------|-----------|--------------|------------------|
| 1년 미만 | 120일 | 120일 | 120일 |
| 1-3년 미만 | 120일 | 150일 | 180일 |
| 3-5년 미만 | 150일 | 180일 | 210일 |
| 5-10년 미만 | 180일 | 210일 | 240일 |
| 10년 이상 | 210일 | 240일 | 270일 |

장애인의 경우 별도 기준:
- 1년 미만: 120일
- 1-3년: 180일
- 3-5년: 210일
- 5-10년: 240일
- 10년 이상: 270일

#### 4. 계산 규정
- **급여율**: 일 평균 임금의 60% (2019년 10월 1일 이후)
- **상한액**: 66,000원/일
- **하한액**: 최저임금(9,860원/시간 기준) × 8시간 × 80%
- **수급자격**: 고용보험 가입기간 180일 이상 (약 6개월)

### 참고 자료
- [고용보험 실업급여 모의계산](https://eiac.ei.go.kr/ei/m/pf/MOW-PF-00-180-C.html)
- 계산기는 위 사이트의 기능을 기반으로 구현됨

### 실행 방법
```bash
cd /Users/hyebin/Documents/DEV_PROJECT/calculator-collection
mojo src/unemployment_calculator/main.mojo
```

### 사용 예시

#### 일반 근로자 계산
```
선택: 1
생년월일 (YYMMDD): 900101
장애인 여부 (y/n): n
가입 시작일 (YYYY-MM-DD): 2020-01-01
가입 종료일 (YYYY-MM-DD): 2024-01-01
1개월 전 월급 (원): 3000000
2개월 전 월급 (원): 3000000
3개월 전 월급 (원): 3000000

결과:
1일 구직급여일액: 60000원
예상 지급일수: 210일
총 예상수급액: 12600000원
```

### 향후 개선 사항 (TODO)

#### 기능 추가
- [ ] 단위 테스트 작성 (tests/ 디렉토리)
- [ ] 2019년 10월 1일 이전 계산 규정 지원 (급여율 50%)
- [ ] CLI 배치 모드 (명령줄 인자를 통한 계산)
- [ ] 결과 저장 기능 (CSV, JSON, TXT)
- [ ] 더 정확한 날짜 계산 로직 (윤년, 월별 일수 정확히 고려)
- [ ] 입력 유효성 검증 강화 (날짜 형식, 범위 체크)
- [ ] 에러 처리 개선

#### 계산기 추가
- [ ] 퇴직금 계산기
- [ ] 연차수당 계산기
- [ ] 4대보험 계산기
- [ ] 근로소득세 계산기
- [ ] 시급/월급 환산 계산기

#### 코드 개선
- [ ] 날짜 계산 라이브러리 사용 (정확한 날짜 연산)
- [ ] 상수 값들 설정 파일로 분리 (최저임금, 상한액 등)
- [ ] 로깅 기능 추가
- [ ] 다국어 지원 (영어, 일본어 등)

### 기술 스택
- **언어**: Mojo 24.5+
- **Python 연동**: Python 3.8+ (input 함수 사용)
- **패키지 구조**: 모듈화된 Mojo 패키지

### 프로젝트 상태
✅ **완료**: 기본 실업급여 계산기 구현 완료
- 3가지 근로자 유형 모두 지원
- REPL 인터페이스 구현
- README 문서화 완료

### 다음 작업 시 체크리스트
1. Mojo 설치 확인: `mojo --version`
2. 프로젝트 디렉토리 이동: `cd /Users/hyebin/Documents/DEV_PROJECT/calculator-collection`
3. 실행 테스트: `mojo src/unemployment_calculator/main.mojo`
4. 새 기능 추가 시: 해당 모듈 파일 수정 후 테스트

### 개발 환경
- **경로**: `/Users/hyebin/Documents/DEV_PROJECT/calculator-collection`
- **Git 저장소**: 초기화 완료 (.git/ 존재)
- **MoAI 설정**: .moai/, .claude/ 디렉토리 존재

### 알려진 제한사항
1. 날짜 계산이 근사치 (월을 30일로 가정)
2. 2019년 10월 1일 이전 규정 미지원
3. 기준보수 등급별 금액이 예시 값 (실제 고용보험 규정 확인 필요)
4. 입력 유효성 검증이 기본적인 수준

---

## 작업 재개 시 참고사항

### 빠른 시작
```bash
# 1. 프로젝트로 이동
cd /Users/hyebin/Documents/DEV_PROJECT/calculator-collection

# 2. 실행
mojo src/unemployment_calculator/main.mojo

# 3. 테스트 (향후 추가 예정)
# mojo test tests/
```

### 파일 구조 이해
- **types.mojo**: 데이터 구조만 정의 (로직 없음)
- **utils.mojo**: 재사용 가능한 헬퍼 함수들
- **calculator.mojo**: 핵심 계산 로직 (3가지 함수)
- **main.mojo**: 사용자 인터페이스 (입출력 처리)

### 새 계산기 추가 방법
1. `types.mojo`에 새 입력/결과 구조체 추가
2. `calculator.mojo`에 계산 함수 추가
3. `main.mojo`에 핸들러 함수 및 메뉴 항목 추가
4. `README.md` 업데이트

### 문제 해결
- **Mojo 파싱 에러**: 문법 확인 (Mojo는 Python과 유사하지만 타입이 엄격함)
- **Import 에러**: `__init__.mojo` 확인
- **실행 에러**: Python 모듈 사용 시 `from python import Python` 확인

---

*마지막 업데이트: 2026-01-27*
*다음 세션에서 이 파일을 참고하여 작업을 이어갈 수 있습니다.*
