package com.example.training;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 経費精算サービスの業務例外。
 *
 * 内部エラーコードを受け取り、外部エラーコードに変換する。
 * ログには内部・外部の両コードを出力し、呼び出し元には外部コードとメッセージのみ公開する。
 */
public class ExpenseException extends RuntimeException {

    private static final Logger log = LoggerFactory.getLogger(ExpenseException.class);

    /** 内部コードと外部コードのマッピング */
    private static ExternalErrorCode toExternal(InternalErrorCode internal) {
        return switch (internal) {
            case EXPENSE_ITEM_NULL -> ExternalErrorCode.E001;
            case EXPENSE_AMOUNT_NON_POSITIVE -> ExternalErrorCode.E002;
        };
    }

    private final ExternalErrorCode externalErrorCode;

    public ExpenseException(InternalErrorCode internalCode) {
        super(toExternal(internalCode).getMessage());
        this.externalErrorCode = toExternal(internalCode);
        log.error("エラー発生 内部コード=[{}] 外部コード=[{}] メッセージ=[{}]",
                internalCode, externalErrorCode.getCode(), externalErrorCode.getMessage());
    }

    public ExternalErrorCode getExternalErrorCode() {
        return externalErrorCode;
    }
}
