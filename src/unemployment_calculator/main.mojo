"""
실업급여 계산기 REPL 메인 프로그램
"""

from python import Python
from .types import (
    Date,
    RegularWorkerInput,
    DailyWorkerInput,
    SelfEmployedInput
)
from .calculator import (
    calculate_regular_worker_benefit,
    calculate_daily_worker_benefit,
    calculate_self_employed_benefit
)
from .utils import parse_date_input


fn print_welcome_message():
    """환영 메시지를 출력합니다."""
    print("=" * 60)
    print("실업급여 계산기")
    print("=" * 60)
    print()
    print("계산하려는 유형을 선택하세요:")
    print("1. 일반 근로자")
    print("2. 일용 근로자")
    print("3. 자영업자")
    print("0. 종료")
    print()


fn get_user_choice() -> Int:
    """사용자로부터 선택을 입력받습니다."""
    var py = Python.import_module("builtins")
    var choice_str = str(py.input("선택: "))

    try:
        return int(choice_str)
    except:
        return -1


fn get_string_input(prompt: String) -> String:
    """문자열 입력을 받습니다."""
    var py = Python.import_module("builtins")
    print(prompt, end="")
    return str(py.input())


fn get_float_input(prompt: String) -> Float64:
    """실수 입력을 받습니다."""
    var py = Python.import_module("builtins")
    print(prompt, end="")
    var input_str = str(py.input())

    try:
        return Float64(input_str)
    except:
        return 0.0


fn get_int_input(prompt: String) -> Int:
    """정수 입력을 받습니다."""
    var py = Python.import_module("builtins")
    print(prompt, end="")
    var input_str = str(py.input())

    try:
        return int(input_str)
    except:
        return 0


fn get_bool_input(prompt: String) -> Bool:
    """Yes/No 입력을 받습니다."""
    var py = Python.import_module("builtins")
    print(prompt + " (y/n): ", end="")
    var input_str = str(py.input()).lower()

    return input_str == "y" or input_str == "yes"


fn handle_regular_worker():
    """일반 근로자 입력 및 계산을 처리합니다."""
    print("\n--- 일반 근로자 실업급여 계산 ---\n")

    # 입력 받기
    var birth_date = get_string_input("생년월일 (YYMMDD, 예: 900101): ")
    var is_disabled = get_bool_input("장애인 여부")

    print("\n가입 시작일 (YYYY-MM-DD, 예: 2020-01-01): ", end="")
    var start_date_str = get_string_input("")
    var insurance_start_date = parse_date_input(start_date_str)

    print("가입 종료일 (YYYY-MM-DD, 예: 2024-01-01): ", end="")
    var end_date_str = get_string_input("")
    var insurance_end_date = parse_date_input(end_date_str)

    print("\n최근 3개월 월급을 입력하세요:")
    var wage1 = get_float_input("1개월 전 월급 (원): ")
    var wage2 = get_float_input("2개월 전 월급 (원): ")
    var wage3 = get_float_input("3개월 전 월급 (원): ")

    var monthly_wages = StaticTuple[Float64, 3](wage1, wage2, wage3)

    # 입력 데이터 생성
    var input_data = RegularWorkerInput(
        birth_date=birth_date,
        is_disabled=is_disabled,
        insurance_start_date=insurance_start_date,
        insurance_end_date=insurance_end_date,
        monthly_wages=monthly_wages
    )

    # 계산 수행
    var result = calculate_regular_worker_benefit(input_data)

    # 결과 출력
    print("\n" + "=" * 60)
    print("계산 결과")
    print("=" * 60)
    print(result.to_string())
    print("=" * 60 + "\n")


fn handle_daily_worker():
    """일용 근로자 입력 및 계산을 처리합니다."""
    print("\n--- 일용 근로자 실업급여 계산 ---\n")

    # 입력 받기
    var birth_date = get_string_input("생년월일 (YYMMDD, 예: 900101): ")
    var is_disabled = get_bool_input("장애인 여부")

    var insurance_years = get_int_input("\n가입 기간 - 년: ")
    var insurance_months = get_int_input("가입 기간 - 월: ")

    print("\n마지막 근무일 (YYYY-MM-DD, 예: 2024-01-01): ", end="")
    var last_work_date_str = get_string_input("")
    var last_work_date = parse_date_input(last_work_date_str)

    print("\n최근 3개월 일급 및 근무일수를 입력하세요:")

    var daily_wage1 = get_float_input("1개월 전 일급 (원): ")
    var work_days1 = get_int_input("1개월 전 근무일수 (일): ")

    var daily_wage2 = get_float_input("2개월 전 일급 (원): ")
    var work_days2 = get_int_input("2개월 전 근무일수 (일): ")

    var daily_wage3 = get_float_input("3개월 전 일급 (원): ")
    var work_days3 = get_int_input("3개월 전 근무일수 (일): ")

    var daily_wages = StaticTuple[Float64, 3](daily_wage1, daily_wage2, daily_wage3)
    var work_days = StaticTuple[Int, 3](work_days1, work_days2, work_days3)

    # 입력 데이터 생성
    var input_data = DailyWorkerInput(
        birth_date=birth_date,
        is_disabled=is_disabled,
        insurance_years=insurance_years,
        insurance_months=insurance_months,
        last_work_date=last_work_date,
        daily_wages=daily_wages,
        work_days=work_days
    )

    # 계산 수행
    var result = calculate_daily_worker_benefit(input_data)

    # 결과 출력
    print("\n" + "=" * 60)
    print("계산 결과")
    print("=" * 60)
    print(result.to_string())
    print("=" * 60 + "\n")


fn handle_self_employed():
    """자영업자 입력 및 계산을 처리합니다."""
    print("\n--- 자영업자 실업급여 계산 ---\n")

    # 입력 받기
    print("가입 시작일 (YYYY-MM-DD, 예: 2020-01-01): ", end="")
    var start_date_str = get_string_input("")
    var insurance_start_date = parse_date_input(start_date_str)

    print("가입 종료일 (YYYY-MM-DD, 예: 2024-01-01): ", end="")
    var end_date_str = get_string_input("")
    var insurance_end_date = parse_date_input(end_date_str)

    print("\n기준보수 등급 (1-7, 숫자가 높을수록 기준보수 높음): ", end="")
    var base_pay_grade = get_int_input("")

    # 입력 데이터 생성
    var input_data = SelfEmployedInput(
        insurance_start_date=insurance_start_date,
        insurance_end_date=insurance_end_date,
        base_pay_grade=base_pay_grade
    )

    # 계산 수행
    var result = calculate_self_employed_benefit(input_data)

    # 결과 출력
    print("\n" + "=" * 60)
    print("계산 결과")
    print("=" * 60)
    print(result.to_string())
    print("=" * 60 + "\n")


fn main():
    """메인 REPL 루프"""
    while True:
        print_welcome_message()
        var choice = get_user_choice()

        if choice == 0:
            print("\n실업급여 계산기를 종료합니다.")
            break
        elif choice == 1:
            handle_regular_worker()
        elif choice == 2:
            handle_daily_worker()
        elif choice == 3:
            handle_self_employed()
        else:
            print("\n잘못된 선택입니다. 다시 선택해주세요.\n")
