"""
실업급여 계산기 유틸리티 함수
"""

from .types import Date


fn days_between_dates(start: Date, end: Date) -> Int:
    """두 날짜 사이의 일수를 계산합니다."""
    # 간단한 근사 계산 (실제로는 더 정확한 계산이 필요)
    var year_diff = end.year - start.year
    var month_diff = end.month - start.month
    var day_diff = end.day - start.day

    return year_diff * 365 + month_diff * 30 + day_diff


fn months_between_dates(start: Date, end: Date) -> Int:
    """두 날짜 사이의 개월수를 계산합니다."""
    var year_diff = end.year - start.year
    var month_diff = end.month - start.month

    return year_diff * 12 + month_diff


fn calculate_age_from_birth_date(birth_date: String, reference_date: Date) -> Int:
    """생년월일로부터 나이를 계산합니다 (YYMMDD 형식)."""
    # birth_date는 YYMMDD 형식 (예: "900101")
    var year_str = birth_date[0:2]
    var birth_year = int(year_str)

    # 2000년 이후 출생인 경우와 그 이전 구분
    if birth_year <= 25:  # 2025년 기준
        birth_year += 2000
    else:
        birth_year += 1900

    return reference_date.year - birth_year


fn get_payment_days_by_age_and_period(age: Int, insurance_months: Int) -> Int:
    """나이와 가입 기간에 따른 지급일수를 반환합니다."""
    # 한국 실업급여 지급일수 기준 (2019년 10월 1일 이후)

    if insurance_months < 12:
        return 120
    elif insurance_months < 36:
        if age < 30:
            return 120
        elif age < 50:
            return 150
        else:  # 50세 이상
            return 180
    elif insurance_months < 60:
        if age < 30:
            return 150
        elif age < 50:
            return 180
        else:  # 50세 이상
            return 210
    elif insurance_months < 120:
        if age < 30:
            return 180
        elif age < 50:
            return 210
        else:  # 50세 이상
            return 240
    else:  # 120개월 (10년) 이상
        if age < 30:
            return 210
        elif age < 50:
            return 240
        else:  # 50세 이상 or 장애인
            return 270

    return 120  # 기본값


fn get_disability_payment_days(insurance_months: Int) -> Int:
    """장애인의 경우 지급일수를 반환합니다."""
    if insurance_months < 12:
        return 120
    elif insurance_months < 36:
        return 180
    elif insurance_months < 60:
        return 210
    elif insurance_months < 120:
        return 240
    else:  # 120개월 이상
        return 270

    return 120  # 기본값


fn calculate_daily_average_wage(total_wage: Float64, total_days: Int) -> Float64:
    """일 평균 임금을 계산합니다."""
    if total_days == 0:
        return 0.0
    return total_wage / Float64(total_days)


fn apply_benefit_rate(daily_avg_wage: Float64, after_2019: Bool = True) -> Float64:
    """급여율을 적용합니다 (2019년 10월 1일 이후 60%, 이전 50%)."""
    if after_2019:
        return daily_avg_wage * 0.6
    else:
        return daily_avg_wage * 0.5


fn apply_benefit_limits(daily_benefit: Float64, minimum_wage: Float64 = 9860.0) -> Float64:
    """상한액과 하한액을 적용합니다.

    Args:
        daily_benefit: 계산된 일일 급여액
        minimum_wage: 시간당 최저임금 (2024년 기준 9,860원)

    Returns:
        조정된 일일 급여액
    """
    # 상한액: 66,000원 (2019년 이후)
    var upper_limit: Float64 = 66000.0

    # 하한액: 최저임금의 80% × 1일 소정근로시간 8시간
    var lower_limit = minimum_wage * 8.0 * 0.8

    if daily_benefit > upper_limit:
        return upper_limit
    elif daily_benefit < lower_limit:
        return lower_limit
    else:
        return daily_benefit


fn validate_insurance_period(months: Int) -> Bool:
    """가입 기간이 180일 이상인지 검증합니다 (약 6개월)."""
    return months >= 6


fn parse_date_input(date_str: String) -> Date:
    """날짜 문자열을 파싱합니다 (YYYY-MM-DD 형식)."""
    # 간단한 구현 - 실제로는 더 robust한 파싱이 필요
    var parts = date_str.split("-")
    var year = int(parts[0])
    var month = int(parts[1])
    var day = int(parts[2])

    return Date(year, month, day)
