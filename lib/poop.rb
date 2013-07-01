module ISO6709

  def signed(num)
    if num < 0
      num.to_s
    else
      "+#{num.to_s}"
    end
  end

end