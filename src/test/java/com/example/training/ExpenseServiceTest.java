package com.example.training;

import static org.assertj.core.api.Assertions.assertThat;

import com.example.training.ExpenseItem.Category;
import java.util.List;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

class ExpenseServiceTest {

    private final ExpenseService service = new ExpenseService();

    @Test
    @DisplayName("交通費: 上限以内なら全額支給される")
    void transportWithinCap() {
        assertThat(service.reimburse(new ExpenseItem(Category.TRANSPORT, 1_200))).isEqualTo(1_200);
    }

    @Test
    @DisplayName("交通費: 上限を超えた分は支給されない（上限3,000円で頭打ち）")
    void transportOverCap() {
        assertThat(service.reimburse(new ExpenseItem(Category.TRANSPORT, 5_000))).isEqualTo(3_000);
    }

    @Test
    @DisplayName("交通費: ちょうど上限額なら全額支給される")
    void transportExactlyCap() {
        assertThat(service.reimburse(new ExpenseItem(Category.TRANSPORT, 3_000))).isEqualTo(3_000);
    }

    @Test
    @DisplayName("食事代: 半額支給・1円未満は切り捨て")
    void mealHalfRoundedDown() {
        assertThat(service.reimburse(new ExpenseItem(Category.MEAL, 1_001))).isEqualTo(500);
    }

    @Test
    @DisplayName("食事代: 偶数額はちょうど半額")
    void mealHalfEven() {
        assertThat(service.reimburse(new ExpenseItem(Category.MEAL, 1_000))).isEqualTo(500);
    }

    @Test
    @DisplayName("その他: 全額支給される")
    void otherFullAmount() {
        assertThat(service.reimburse(new ExpenseItem(Category.OTHER, 8_000))).isEqualTo(8_000);
    }

    @Test
    @DisplayName("合計: 全明細の支給額が合算される")
    void totalSumsReimbursedAmounts() {
        var items = List.of(
                new ExpenseItem(Category.TRANSPORT, 5_000), // -> 3,000
                new ExpenseItem(Category.MEAL, 1_000),      // -> 500
                new ExpenseItem(Category.OTHER, 2_000));    // -> 2,000
        assertThat(service.total(items)).isEqualTo(5_500);
    }

    @Test
    @DisplayName("合計: 明細が空なら0円")
    void totalEmpty() {
        assertThat(service.total(List.of())).isZero();
    }
}
