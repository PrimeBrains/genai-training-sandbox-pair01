package com.example.training;

/**
 * 経費精算の1明細。
 *
 * @param category 費目（TRANSPORT: 交通費, MEAL: 食事代, OTHER: その他）
 * @param amount   金額（円）
 */
public record ExpenseItem(Category category, int amount) {

    public enum Category {
        TRANSPORT, MEAL, OTHER
    }
}
