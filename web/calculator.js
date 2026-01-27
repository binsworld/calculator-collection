// ============================================
// 실업급여 계산기 JavaScript
// ============================================

// 상수 정의
const CONSTANTS = {
    BENEFIT_RATE: 0.6, // 급여율 60% (2019년 이후)
    UPPER_LIMIT: 66000, // 상한액
    MINIMUM_WAGE: 9860, // 2024년 최저임금 (시급)
    MINIMUM_INSURANCE_MONTHS: 6, // 최소 가입기간 (개월)
    SELF_EMPLOYED_BASE_PAY: {
        1: 1000000,
        2: 1500000,
        3: 2000000,
        4: 2500000,
        5: 3000000,
        6: 3500000,
        7: 4000000
    }
};

// ============================================
// 유틸리티 함수
// ============================================

/**
 * 두 날짜 사이의 개월수 계산
 */
function monthsBetweenDates(startDate, endDate) {
    const start = new Date(startDate);
    const end = new Date(endDate);

    const yearDiff = end.getFullYear() - start.getFullYear();
    const monthDiff = end.getMonth() - start.getMonth();

    return yearDiff * 12 + monthDiff;
}

/**
 * 생년월일로부터 나이 계산 (YYMMDD 형식)
 */
function calculateAge(birthDateStr, referenceDate) {
    // YYMMDD 형식 파싱
    const yy = parseInt(birthDateStr.substring(0, 2));
    const mm = parseInt(birthDateStr.substring(2, 4));
    const dd = parseInt(birthDateStr.substring(4, 6));

    // 2000년 이후/이전 구분
    const birthYear = yy <= 25 ? 2000 + yy : 1900 + yy;

    const birthDate = new Date(birthYear, mm - 1, dd);
    const refDate = new Date(referenceDate);

    let age = refDate.getFullYear() - birthDate.getFullYear();
    const monthDiff = refDate.getMonth() - birthDate.getMonth();

    if (monthDiff < 0 || (monthDiff === 0 && refDate.getDate() < birthDate.getDate())) {
        age--;
    }

    return age;
}

/**
 * 나이와 가입기간에 따른 지급일수 결정
 */
function getPaymentDays(age, insuranceMonths, isDisabled) {
    if (isDisabled) {
        return getDisabilityPaymentDays(insuranceMonths);
    }

    if (insuranceMonths < 12) {
        return 120;
    } else if (insuranceMonths < 36) {
        if (age < 30) return 120;
        else if (age < 50) return 150;
        else return 180;
    } else if (insuranceMonths < 60) {
        if (age < 30) return 150;
        else if (age < 50) return 180;
        else return 210;
    } else if (insuranceMonths < 120) {
        if (age < 30) return 180;
        else if (age < 50) return 210;
        else return 240;
    } else {
        if (age < 30) return 210;
        else if (age < 50) return 240;
        else return 270;
    }
}

/**
 * 장애인 지급일수 결정
 */
function getDisabilityPaymentDays(insuranceMonths) {
    if (insuranceMonths < 12) return 120;
    else if (insuranceMonths < 36) return 180;
    else if (insuranceMonths < 60) return 210;
    else if (insuranceMonths < 120) return 240;
    else return 270;
}

/**
 * 급여율 적용 (60%)
 */
function applyBenefitRate(dailyAvgWage) {
    return dailyAvgWage * CONSTANTS.BENEFIT_RATE;
}

/**
 * 상한액/하한액 적용
 */
function applyBenefitLimits(dailyBenefit) {
    const lowerLimit = CONSTANTS.MINIMUM_WAGE * 8 * 0.8;

    if (dailyBenefit > CONSTANTS.UPPER_LIMIT) {
        return CONSTANTS.UPPER_LIMIT;
    } else if (dailyBenefit < lowerLimit) {
        return lowerLimit;
    } else {
        return dailyBenefit;
    }
}

/**
 * 가입기간 검증 (180일 이상)
 */
function validateInsurancePeriod(months) {
    return months >= CONSTANTS.MINIMUM_INSURANCE_MONTHS;
}

/**
 * 금액 포맷팅 (천 단위 콤마)
 */
function formatCurrency(amount) {
    return Math.floor(amount).toLocaleString('ko-KR') + '원';
}

// ============================================
// 계산 함수
// ============================================

/**
 * 일반 근로자 실업급여 계산
 */
function calculateRegularWorkerBenefit(input) {
    // 1. 가입기간 계산
    const insuranceMonths = monthsBetweenDates(input.startDate, input.endDate);

    // 2. 가입기간 검증
    if (!validateInsurancePeriod(insuranceMonths)) {
        return {
            isEligible: false,
            errorMessage: '가입 기간이 180일(약 6개월) 미만입니다.'
        };
    }

    // 3. 나이 계산
    const age = calculateAge(input.birthDate, input.endDate);

    // 4. 최근 3개월 평균 임금
    const totalWage = input.wages.reduce((sum, wage) => sum + wage, 0);
    const avgMonthlyWage = totalWage / 3;

    // 5. 일 평균 임금
    const dailyAvgWage = avgMonthlyWage / 30;

    // 6. 급여율 적용
    let dailyBenefit = applyBenefitRate(dailyAvgWage);

    // 7. 상한액/하한액 적용
    dailyBenefit = applyBenefitLimits(dailyBenefit);

    // 8. 지급일수 결정
    const paymentDays = getPaymentDays(age, insuranceMonths, input.isDisabled);

    // 9. 총 수급액
    const totalBenefit = dailyBenefit * paymentDays;

    return {
        isEligible: true,
        dailyBenefit: dailyBenefit,
        paymentDays: paymentDays,
        totalBenefit: totalBenefit
    };
}

/**
 * 일용근로자 실업급여 계산
 */
function calculateDailyWorkerBenefit(input) {
    // 1. 가입기간 계산
    const insuranceMonths = input.years * 12 + input.months;

    // 2. 가입기간 검증
    if (!validateInsurancePeriod(insuranceMonths)) {
        return {
            isEligible: false,
            errorMessage: '가입 기간이 180일(약 6개월) 미만입니다.'
        };
    }

    // 3. 나이 계산
    const age = calculateAge(input.birthDate, input.lastWorkDate);

    // 4. 최근 3개월 총 임금 및 근무일수
    let totalWage = 0;
    let totalDays = 0;

    for (let i = 0; i < 3; i++) {
        totalWage += input.wages[i] * input.workDays[i];
        totalDays += input.workDays[i];
    }

    // 5. 일 평균 임금
    const dailyAvgWage = totalDays > 0 ? totalWage / totalDays : 0;

    if (dailyAvgWage === 0) {
        return {
            isEligible: false,
            errorMessage: '유효한 근무 일수가 없습니다.'
        };
    }

    // 6. 급여율 적용
    let dailyBenefit = applyBenefitRate(dailyAvgWage);

    // 7. 상한액/하한액 적용
    dailyBenefit = applyBenefitLimits(dailyBenefit);

    // 8. 지급일수 결정
    const paymentDays = getPaymentDays(age, insuranceMonths, input.isDisabled);

    // 9. 총 수급액
    const totalBenefit = dailyBenefit * paymentDays;

    return {
        isEligible: true,
        dailyBenefit: dailyBenefit,
        paymentDays: paymentDays,
        totalBenefit: totalBenefit
    };
}

/**
 * 자영업자 실업급여 계산
 */
function calculateSelfEmployedBenefit(input) {
    // 1. 가입기간 계산
    const insuranceMonths = monthsBetweenDates(input.startDate, input.endDate);

    // 2. 가입기간 검증
    if (!validateInsurancePeriod(insuranceMonths)) {
        return {
            isEligible: false,
            errorMessage: '가입 기간이 180일(약 6개월) 미만입니다.'
        };
    }

    // 3. 기준보수 등급별 월 기준보수
    const monthlyBasePay = CONSTANTS.SELF_EMPLOYED_BASE_PAY[input.grade] || 2000000;

    // 4. 일 평균 임금
    const dailyAvgWage = monthlyBasePay / 30;

    // 5. 급여율 적용
    let dailyBenefit = applyBenefitRate(dailyAvgWage);

    // 6. 상한액/하한액 적용
    dailyBenefit = applyBenefitLimits(dailyBenefit);

    // 7. 지급일수 결정 (50세 이상 기준)
    const paymentDays = getPaymentDays(50, insuranceMonths, false);

    // 8. 총 수급액
    const totalBenefit = dailyBenefit * paymentDays;

    return {
        isEligible: true,
        dailyBenefit: dailyBenefit,
        paymentDays: paymentDays,
        totalBenefit: totalBenefit
    };
}

// ============================================
// UI 함수
// ============================================

/**
 * 탭 전환
 */
function switchTab(tabName) {
    // 모든 탭 버튼 비활성화
    document.querySelectorAll('.tab-button').forEach(btn => {
        btn.classList.remove('active');
    });

    // 모든 탭 콘텐츠 숨김
    document.querySelectorAll('.tab-content').forEach(content => {
        content.classList.remove('active');
    });

    // 선택된 탭 활성화
    event.target.classList.add('active');
    document.getElementById(tabName + '-tab').classList.add('active');

    // 결과 영역 숨김
    document.getElementById('result-area').style.display = 'none';
}

/**
 * 폼 초기화
 */
function resetForm(formType) {
    document.getElementById(formType + '-form').reset();
    document.getElementById('result-area').style.display = 'none';
}

/**
 * 결과 표시
 */
function displayResult(result) {
    const resultArea = document.getElementById('result-area');
    const resultContent = document.getElementById('result-content');

    if (!result.isEligible) {
        resultContent.innerHTML = `
            <div class="result-error">
                <strong>수급 자격 없음</strong>
                <p>${result.errorMessage}</p>
            </div>
        `;
    } else {
        resultContent.innerHTML = `
            <div class="result-item">
                <span class="result-label">1일 구직급여일액</span>
                <span class="result-value">${formatCurrency(result.dailyBenefit)}</span>
            </div>
            <div class="result-item">
                <span class="result-label">예상 지급일수</span>
                <span class="result-value">${result.paymentDays}일</span>
            </div>
            <div class="result-item">
                <span class="result-label">총 예상수급액</span>
                <span class="result-value total">${formatCurrency(result.totalBenefit)}</span>
            </div>
        `;
    }

    resultArea.style.display = 'block';
    resultArea.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

// ============================================
// 이벤트 리스너
// ============================================

document.addEventListener('DOMContentLoaded', () => {
    // 일반 근로자 폼 제출
    document.getElementById('regular-form').addEventListener('submit', (e) => {
        e.preventDefault();

        const input = {
            birthDate: document.getElementById('regular-birth').value,
            isDisabled: document.getElementById('regular-disabled').checked,
            startDate: document.getElementById('regular-start').value,
            endDate: document.getElementById('regular-end').value,
            wages: [
                parseFloat(document.getElementById('regular-wage1').value),
                parseFloat(document.getElementById('regular-wage2').value),
                parseFloat(document.getElementById('regular-wage3').value)
            ]
        };

        const result = calculateRegularWorkerBenefit(input);
        displayResult(result);
    });

    // 일용근로자 폼 제출
    document.getElementById('daily-form').addEventListener('submit', (e) => {
        e.preventDefault();

        const input = {
            birthDate: document.getElementById('daily-birth').value,
            isDisabled: document.getElementById('daily-disabled').checked,
            years: parseInt(document.getElementById('daily-years').value),
            months: parseInt(document.getElementById('daily-months').value),
            lastWorkDate: document.getElementById('daily-lastwork').value,
            wages: [
                parseFloat(document.getElementById('daily-wage1').value),
                parseFloat(document.getElementById('daily-wage2').value),
                parseFloat(document.getElementById('daily-wage3').value)
            ],
            workDays: [
                parseInt(document.getElementById('daily-days1').value),
                parseInt(document.getElementById('daily-days2').value),
                parseInt(document.getElementById('daily-days3').value)
            ]
        };

        const result = calculateDailyWorkerBenefit(input);
        displayResult(result);
    });

    // 자영업자 폼 제출
    document.getElementById('self-form').addEventListener('submit', (e) => {
        e.preventDefault();

        const input = {
            startDate: document.getElementById('self-start').value,
            endDate: document.getElementById('self-end').value,
            grade: parseInt(document.getElementById('self-grade').value)
        };

        const result = calculateSelfEmployedBenefit(input);
        displayResult(result);
    });
});
