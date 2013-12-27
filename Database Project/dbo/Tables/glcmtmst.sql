CREATE TABLE [dbo].[glcmtmst] (
    [glcmt_acct1_8]     INT         NOT NULL,
    [glcmt_acct9_16]    INT         NOT NULL,
    [glcmt_type]        CHAR (2)    NOT NULL,
    [glcmt_comment_1]   CHAR (75)   NULL,
    [glcmt_comment_2]   CHAR (75)   NULL,
    [glcmt_comment_3]   CHAR (75)   NULL,
    [glcmt_comment_4]   CHAR (75)   NULL,
    [glcmt_comment_5]   CHAR (75)   NULL,
    [glcmt_comment_6]   CHAR (75)   NULL,
    [glcmt_comment_7]   CHAR (75)   NULL,
    [glcmt_comment_8]   CHAR (75)   NULL,
    [glcmt_comment_9]   CHAR (75)   NULL,
    [glcmt_comment_10]  CHAR (75)   NULL,
    [glcmt_comment_11]  CHAR (75)   NULL,
    [glcmt_comment_12]  CHAR (75)   NULL,
    [glcmt_comment_13]  CHAR (75)   NULL,
    [glcmt_comment_14]  CHAR (75)   NULL,
    [glcmt_comment_15]  CHAR (75)   NULL,
    [glcmt_user_id]     CHAR (16)   NULL,
    [glcmt_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glcmtmst] PRIMARY KEY NONCLUSTERED ([glcmt_acct1_8] ASC, [glcmt_acct9_16] ASC, [glcmt_type] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iglcmtmst0]
    ON [dbo].[glcmtmst]([glcmt_acct1_8] ASC, [glcmt_acct9_16] ASC, [glcmt_type] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[glcmtmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[glcmtmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[glcmtmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[glcmtmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[glcmtmst] TO PUBLIC
    AS [dbo];

