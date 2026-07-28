package com.example.training;

/** 外部エラーコード。クライアントへのレスポンスに使用する。 */
public enum ExternalErrorCode {
    E001("E001", "リクエストが不正です"),
    E002("E002", "金額は1円以上で入力してください");

    private final String code;
    private final String message;

    ExternalErrorCode(String code, String message) {
        this.code = code;
        this.message = message;
    }

    public String getCode() { return code; }
    public String getMessage() { return message; }
}
