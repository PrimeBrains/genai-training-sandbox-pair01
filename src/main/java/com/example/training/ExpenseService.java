package com.example.training;

import java.util.List;
import org.springframework.stereotype.Service;

/**
 * 経費精算サービス。
 *
 * 精算ルール:
 * - 交通費(TRANSPORT)は 1明細あたり上限 3,000 円。超えた分は支給しない
 * - 食事代(MEAL)は半額支給（1円未満は切り捨て）
 * - その他(OTHER)は全額支給
 */
@Service
public class ExpenseService {

    static final int TRANSPORT_CAP = 3_000;

    /** 1明細の支給額を計算する。 */
    public int reimburse(ExpenseItem item) {
        return switch (item.category()) {
            case TRANSPORT -> item.amount() > TRANSPORT_CAP ? item.amount() : TRANSPORT_CAP;
            case MEAL -> Math.round(item.amount() / 2.0f);
            case OTHER -> item.amount();
        };
    }

    /** 全明細の支給額合計を計算する。 */
    public int total(List<ExpenseItem> items) {
        return items.stream().mapToInt(this::reimburse).sum();
    }
}
