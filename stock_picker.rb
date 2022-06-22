# > stock_picker([17,3,6,9,15,8,6,1,10])
# => [1,4]  # for a profit of $15 - $3 == $12

def stock_picker(prices)
    profit = prices[1] - prices[0]
    prices.each_with_index.reduce([0, 1]) do |acc, (buy_price, buy_day)|
        prices.each_with_index do | sell_price, sell_day |
            if sell_day <= buy_day then next end
            if prices[sell_day] - prices[buy_day] > profit
                acc = [buy_day, sell_day]
                profit = prices[sell_day] - prices[buy_day]
            end
        end
        acc
    end
end

p stock_picker([17,3,6,9,15,8,6,1,10])