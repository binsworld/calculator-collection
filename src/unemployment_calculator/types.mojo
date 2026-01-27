"""
실업급여 계산기 데이터 타입 정의
"""

from python import Python

struct Date:
    """날짜를 표현하는 구조체"""
    var year: Int
    var month: Int
    var day: Int

    fn __init__(inout self, year: Int, month: Int, day: Int):
        self.year = year
        self.month = month
        self.day = day

    fn to_string(self) -> String:
        return String(self.year) + "-" + String(self.month).zfill(2) + "-" + String(self.day).zfill(2)


struct RegularWorkerInput:
    """일반 근로자 입력 데이터"""
    var birth_date: String  # YYMMDD format
    var is_disabled: Bool
    var insurance_start_date: Date
    var insurance_end_date: Date
    var monthly_wages: StaticTuple[Float64, 3]  # 최근 3개월 월급

    fn __init__(
        inout self,
        birth_date: String,
        is_disabled: Bool,
        insurance_start_date: Date,
        insurance_end_date: Date,
        monthly_wages: StaticTuple[Float64, 3]
    ):
        self.birth_date = birth_date
        self.is_disabled = is_disabled
        self.insurance_start_date = insurance_start_date
        self.insurance_end_date = insurance_end_date
        self.monthly_wages = monthly_wages


struct DailyWorkerInput:
    """일용근로자 입력 데이터"""
    var birth_date: String
    var is_disabled: Bool
    var insurance_years: Int
    var insurance_months: Int
    var last_work_date: Date
    var daily_wages: StaticTuple[Float64, 3]  # 최근 3개월 일급
    var work_days: StaticTuple[Int, 3]  # 최근 3개월 근무일수

    fn __init__(
        inout self,
        birth_date: String,
        is_disabled: Bool,
        insurance_years: Int,
        insurance_months: Int,
        last_work_date: Date,
        daily_wages: StaticTuple[Float64, 3],
        work_days: StaticTuple[Int, 3]
    ):
        self.birth_date = birth_date
        self.is_disabled = is_disabled
        self.insurance_years = insurance_years
        self.insurance_months = insurance_months
        self.last_work_date = last_work_date
        self.daily_wages = daily_wages
        self.work_days = work_days


struct SelfEmployedInput:
    """자영업자 입력 데이터"""
    var insurance_start_date: Date
    var insurance_end_date: Date
    var base_pay_grade: Int  # 1-7 등급

    fn __init__(
        inout self,
        insurance_start_date: Date,
        insurance_end_date: Date,
        base_pay_grade: Int
    ):
        self.insurance_start_date = insurance_start_date
        self.insurance_end_date = insurance_end_date
        self.base_pay_grade = base_pay_grade


struct UnemploymentBenefitResult:
    """실업급여 계산 결과"""
    var daily_benefit: Float64  # 1일 구직급여일액
    var payment_days: Int  # 예상 지급일수
    var total_benefit: Float64  # 총 예상수급액
    var is_eligible: Bool  # 수급 자격 여부
    var error_message: String  # 오류 메시지 (있을 경우)

    fn __init__(
        inout self,
        daily_benefit: Float64,
        payment_days: Int,
        total_benefit: Float64,
        is_eligible: Bool,
        error_message: String = ""
    ):
        self.daily_benefit = daily_benefit
        self.payment_days = payment_days
        self.total_benefit = total_benefit
        self.is_eligible = is_eligible
        self.error_message = error_message

    fn to_string(self) -> String:
        if not self.is_eligible:
            return "수급 자격 없음: " + self.error_message

        return (
            "1일 구직급여일액: " + String(int(self.daily_benefit)) + "원\n" +
            "예상 지급일수: " + String(self.payment_days) + "일\n" +
            "총 예상수급액: " + String(int(self.total_benefit)) + "원"
        )
