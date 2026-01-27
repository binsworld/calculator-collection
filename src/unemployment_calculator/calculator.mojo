"""
실업급여 계산 로직
"""

from .types import (
    RegularWorkerInput,
    DailyWorkerInput,
    SelfEmployedInput,
    UnemploymentBenefitResult,
    Date
)
from .utils import (
    months_between_dates,
    calculate_age_from_birth_date,
    get_payment_days_by_age_and_period,
    get_disability_payment_days,
    calculate_daily_average_wage,
    apply_benefit_rate,
    apply_benefit_limits,
    validate_insurance_period
)


fn calculate_regular_worker_benefit(input: RegularWorkerInput) -> UnemploymentBenefitResult:
    """일반 근로자의 실업급여를 계산합니다.

    Args:
        input: 일반 근로자 입력 데이터

    Returns:
        실업급여 계산 결과
    """
    # 1. 가입 기간 계산
    var insurance_months = months_between_dates(
        input.insurance_start_date,
        input.insurance_end_date
    )

    # 2. 가입 기간 검증 (180일 이상)
    if not validate_insurance_period(insurance_months):
        return UnemploymentBenefitResult(
            daily_benefit=0.0,
            payment_days=0,
            total_benefit=0.0,
            is_eligible=False,
            error_message="가입 기간이 180일(약 6개월) 미만입니다."
        )

    # 3. 나이 계산
    var age = calculate_age_from_birth_date(
        input.birth_date,
        input.insurance_end_date
    )

    # 4. 최근 3개월 평균 임금 계산
    var total_wage: Float64 = 0.0
    for i in range(3):
        total_wage += input.monthly_wages[i]
    var avg_monthly_wage = total_wage / 3.0

    # 5. 일 평균 임금 계산 (월 평균 / 30)
    var daily_avg_wage = avg_monthly_wage / 30.0

    # 6. 급여율 적용 (60%)
    var daily_benefit = apply_benefit_rate(daily_avg_wage, after_2019=True)

    # 7. 상한액/하한액 적용
    daily_benefit = apply_benefit_limits(daily_benefit)

    # 8. 지급일수 결정
    var payment_days: Int
    if input.is_disabled:
        payment_days = get_disability_payment_days(insurance_months)
    else:
        payment_days = get_payment_days_by_age_and_period(age, insurance_months)

    # 9. 총 수급액 계산
    var total_benefit = daily_benefit * Float64(payment_days)

    return UnemploymentBenefitResult(
        daily_benefit=daily_benefit,
        payment_days=payment_days,
        total_benefit=total_benefit,
        is_eligible=True,
        error_message=""
    )


fn calculate_daily_worker_benefit(input: DailyWorkerInput) -> UnemploymentBenefitResult:
    """일용근로자의 실업급여를 계산합니다.

    Args:
        input: 일용근로자 입력 데이터

    Returns:
        실업급여 계산 결과
    """
    # 1. 가입 기간 계산
    var insurance_months = input.insurance_years * 12 + input.insurance_months

    # 2. 가입 기간 검증 (180일 이상)
    if not validate_insurance_period(insurance_months):
        return UnemploymentBenefitResult(
            daily_benefit=0.0,
            payment_days=0,
            total_benefit=0.0,
            is_eligible=False,
            error_message="가입 기간이 180일(약 6개월) 미만입니다."
        )

    # 3. 나이 계산
    var age = calculate_age_from_birth_date(
        input.birth_date,
        input.last_work_date
    )

    # 4. 최근 3개월 총 임금 및 근무일수 계산
    var total_wage: Float64 = 0.0
    var total_work_days: Int = 0

    for i in range(3):
        total_wage += input.daily_wages[i] * Float64(input.work_days[i])
        total_work_days += input.work_days[i]

    # 5. 일 평균 임금 계산
    var daily_avg_wage = calculate_daily_average_wage(total_wage, total_work_days)

    # 6. 급여율 적용 (60%)
    var daily_benefit = apply_benefit_rate(daily_avg_wage, after_2019=True)

    # 7. 상한액/하한액 적용
    daily_benefit = apply_benefit_limits(daily_benefit)

    # 8. 지급일수 결정
    var payment_days: Int
    if input.is_disabled:
        payment_days = get_disability_payment_days(insurance_months)
    else:
        payment_days = get_payment_days_by_age_and_period(age, insurance_months)

    # 9. 총 수급액 계산
    var total_benefit = daily_benefit * Float64(payment_days)

    return UnemploymentBenefitResult(
        daily_benefit=daily_benefit,
        payment_days=payment_days,
        total_benefit=total_benefit,
        is_eligible=True,
        error_message=""
    )


fn calculate_self_employed_benefit(input: SelfEmployedInput) -> UnemploymentBenefitResult:
    """자영업자의 실업급여를 계산합니다.

    Args:
        input: 자영업자 입력 데이터

    Returns:
        실업급여 계산 결과
    """
    # 1. 가입 기간 계산
    var insurance_months = months_between_dates(
        input.insurance_start_date,
        input.insurance_end_date
    )

    # 2. 가입 기간 검증 (180일 이상)
    if not validate_insurance_period(insurance_months):
        return UnemploymentBenefitResult(
            daily_benefit=0.0,
            payment_days=0,
            total_benefit=0.0,
            is_eligible=False,
            error_message="가입 기간이 180일(약 6개월) 미만입니다."
        )

    # 3. 기준보수 등급별 월 기준보수 (2024년 기준, 예시)
    var monthly_base_pay: Float64
    if input.base_pay_grade == 1:
        monthly_base_pay = 1_000_000.0
    elif input.base_pay_grade == 2:
        monthly_base_pay = 1_500_000.0
    elif input.base_pay_grade == 3:
        monthly_base_pay = 2_000_000.0
    elif input.base_pay_grade == 4:
        monthly_base_pay = 2_500_000.0
    elif input.base_pay_grade == 5:
        monthly_base_pay = 3_000_000.0
    elif input.base_pay_grade == 6:
        monthly_base_pay = 3_500_000.0
    elif input.base_pay_grade == 7:
        monthly_base_pay = 4_000_000.0
    else:
        monthly_base_pay = 2_000_000.0  # 기본값

    # 4. 일 평균 임금 계산
    var daily_avg_wage = monthly_base_pay / 30.0

    # 5. 급여율 적용 (60%)
    var daily_benefit = apply_benefit_rate(daily_avg_wage, after_2019=True)

    # 6. 상한액/하한액 적용
    daily_benefit = apply_benefit_limits(daily_benefit)

    # 7. 지급일수 결정 (자영업자는 나이 정보 없이 가입기간만 고려)
    # 50세 이상 기준 적용
    var payment_days = get_payment_days_by_age_and_period(50, insurance_months)

    # 8. 총 수급액 계산
    var total_benefit = daily_benefit * Float64(payment_days)

    return UnemploymentBenefitResult(
        daily_benefit=daily_benefit,
        payment_days=payment_days,
        total_benefit=total_benefit,
        is_eligible=True,
        error_message=""
    )
