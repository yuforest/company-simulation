class Constants
  KISOKOUZYO_FOR_INCOME_TAX = 480000
  KISOKOUZYO_FOR_RESIDENT_TAX = 430000
  AOIRO_KOUZYO = 650000
  BASIC_RESIDENT_TAX_FOR_COMPANY = 70000
end

def micro_company_with_independent_worker(income: 0, company_sales: 0)
  return remaining
end

class IndependentWorkerWithMicroCompany
  def initialize(income: 0, company_sales: 0)
    # 月額報酬45000円払うためにはこのくらいは必要
    raise if company_sales < 650000

    # 会社側の利益と個人の利益を合わせたものがincome
    @income = income - company_sales
    @company_sales = company_sales - koteihi
  end

  def koteihi
    30000
  end

  def syotoku_for_resident_tax
    @income - Constants::AOIRO_KOUZYO - Constants::KISOKOUZYO_FOR_RESIDENT_TAX + remaining_as_company_menber
  end

  def resident_tax
    (syotoku_for_resident_tax * 0.1).floor + 5000
  end

  def syotoku_for_income_tax
    @income - Constants::AOIRO_KOUZYO - Constants::KISOKOUZYO_FOR_INCOME_TAX + remaining_as_company_menber
  end

  def income_tax
    InsomeTax.new(syotoku_for_income_tax).calculate
  end

  def zeiritu
    InsomeTax.new(syotoku_for_income_tax).zeiritu
  end

  def remaining_as_indepent_worker
    @income - resident_tax - income_tax
  end

  # 月収を45000で固定した場合
  def remaining_as_company_menber
    33959 * 12
  end

  # 月収を45000で固定した場合
  def company_remaining
    ((@company_sales - (56627 * 12) - Constants::BASIC_RESIDENT_TAX_FOR_COMPANY) * 0.7).floor
  end

  def remaining
    remaining_as_indepent_worker + remaining_as_company_menber
  end
end


# 個人事業主の手残りを計算(青色申告を想定)
class IndependentWorker
  def initialize(income: 0)
    @income = income
  end

  def syotoku_for_hokenryo
    @income - Constants::KISOKOUZYO_FOR_RESIDENT_TAX
  end

  def kiso_hokrnryo
    [(syotoku_for_hokenryo * 0.0713).floor + 38800, 630000].min
  end

  def kouki_koureisya_hokenryo
    [(syotoku_for_hokenryo * 0.0241).floor + 13220, 190000].min
  end

  def hokenryo
    kiso_hokrnryo + kouki_koureisya_hokenryo
  end

  def pension
    16590 * 12
  end

  def syotoku_for_resident_tax
    @income - Constants::AOIRO_KOUZYO - Constants::KISOKOUZYO_FOR_RESIDENT_TAX - pension - hokenryo
  end

  def resident_tax
    (syotoku_for_resident_tax * 0.1).floor + 5000
  end

  def syotoku_for_income_tax
    @income - Constants::AOIRO_KOUZYO - Constants::KISOKOUZYO_FOR_INCOME_TAX - pension - hokenryo
  end

  def income_tax
    InsomeTax.new(syotoku_for_income_tax).calculate
  end

  def zeiritu
    InsomeTax.new(syotoku_for_income_tax).zeiritu
  end

  def remaining
    @income - pension - hokenryo - resident_tax - income_tax
  end
end

class InsomeTax
  def initialize(syotoku_for_income_tax)
    @syotoku_for_income_tax = syotoku_for_income_tax
  end

  def calculate
    (@syotoku_for_income_tax * zeiritu).floor - kouzyo
  end

  def zeiritu
    return 0.05 if @syotoku_for_income_tax <= 1950000
    return 0.1 if @syotoku_for_income_tax > 1950000 && @syotoku_for_income_tax <= 3300000
    return 0.2 if @syotoku_for_income_tax > 3300000 && @syotoku_for_income_tax <= 6950000
    return 0.23 if @syotoku_for_income_tax > 6950000 && @syotoku_for_income_tax <= 9000000
    return 0.33 if @syotoku_for_income_tax > 9000000 && @syotoku_for_income_tax <= 18000000
    return 0.40 if @syotoku_for_income_tax > 18000000 && @syotoku_for_income_tax <= 40000000
    0.45
  end

  def kouzyo
    return 0 if @syotoku_for_income_tax <= 1950000
    return 97500 if @syotoku_for_income_tax > 1950000 && @syotoku_for_income_tax <= 3300000
    return 427000 if @syotoku_for_income_tax > 3300000 && @syotoku_for_income_tax <= 6950000
    return 636000 if @syotoku_for_income_tax > 6950000 && @syotoku_for_income_tax <= 9000000
    return 1536000 if @syotoku_for_income_tax > 9000000 && @syotoku_for_income_tax <= 18000000
    return 2796000 if @syotoku_for_income_tax > 18000000 && @syotoku_for_income_tax <= 40000000
    4796000
  end
end

independent_worker_with_micro_company = IndependentWorkerWithMicroCompany.new(income: ARGV[0].to_i, company_sales: ARGV[1].to_i)
puts "個人の手残り(個人事業+マイクロ法人): #{independent_worker_with_micro_company.remaining}"
# puts "個人の税率(個人事業+マイクロ法人): #{independent_worker_with_micro_company.zeiritu}"
# puts "会社の手残り(個人事業+マイクロ法人): #{independent_worker_with_micro_company.company_remaining}"
# puts "個人の所得(個人事業+マイクロ法人): #{independent_worker_with_micro_company.syotoku_for_income_tax}"
# puts "個人の所得税(個人事業+マイクロ法人): #{independent_worker_with_micro_company.income_tax}"

puts "\n"
independent_worker = IndependentWorker.new(income: ARGV[0].to_i)
# puts "社会保険料(個人事業主): #{independent_worker.hokenryo}"
# puts "税率(個人事業主): #{independent_worker.zeiritu}"
puts "個人の手残り: (個人事業主): #{independent_worker.remaining}"
# puts "個人の所得(個人事業主): #{independent_worker.syotoku_for_income_tax}"
# puts "個人の所得税(個人事業主): #{independent_worker.income_tax}"