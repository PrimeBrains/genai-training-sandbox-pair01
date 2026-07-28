package com.example.training;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * 経費精算サービスの業務例外。
 *
 * 各スロー箇所で数値の内部コードを指定する。
 * ログには内部・外部の両コードを出力し、呼び出し元には外部コードとメッセージのみ公開する。
 */
public class ExpenseException extends RuntimeException {

    private static final Logger log = LoggerFactory.getLogger(ExpenseException.class);

    private final ExternalErrorCode externalErrorCode;

    public ExpenseException(int internalCode, ExternalErrorCode externalErrorCode) {
        super(externalErrorCode.getMessage());
        this.externalErrorCode = externalErrorCode;
        log.error("エラー発生 内部コード=[{}] 外部コード=[{}] メッセージ=[{}]",
                internalCode, externalErrorCode.getCode(), externalErrorCode.getMessage());
    }

    public ExternalErrorCode getExternalErrorCode() {
        return externalErrorCode;
    }
}
