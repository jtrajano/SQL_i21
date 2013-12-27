CREATE TABLE [dbo].[jdmrcmst] (
    [jdmrc_merchant_no]        CHAR (8)    NOT NULL,
    [jdmrc_product_line]       CHAR (10)   NOT NULL,
    [jdmrc_merchant_name]      CHAR (50)   NULL,
    [jdmrc_legal_ivc_disclos1] CHAR (50)   NULL,
    [jdmrc_legal_ivc_disclos2] CHAR (50)   NULL,
    [jdmrc_legal_ivc_disclos3] CHAR (50)   NULL,
    [jdmrc_legal_ivc_disclos4] CHAR (50)   NULL,
    [jdmrc_legal_ivc_disclos5] CHAR (50)   NULL,
    [jdmrc_legal_ivc_disclos6] CHAR (50)   NULL,
    [jdmrc_legal_ivc_disclos7] CHAR (50)   NULL,
    [jdmrc_locale]             CHAR (5)    NULL,
    [jdmrc_ivr_phone_no]       BIGINT      NULL,
    [jdmrc_timestamp]          CHAR (25)   NULL,
    [jdmrc_user_id]            CHAR (16)   NULL,
    [jdmrc_user_rev_dt]        INT         NULL,
    [A4GLIdentity]             NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_jdmrcmst] PRIMARY KEY NONCLUSTERED ([jdmrc_merchant_no] ASC, [jdmrc_product_line] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Ijdmrcmst0]
    ON [dbo].[jdmrcmst]([jdmrc_merchant_no] ASC, [jdmrc_product_line] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdmrcmst1]
    ON [dbo].[jdmrcmst]([jdmrc_product_line] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[jdmrcmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[jdmrcmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[jdmrcmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[jdmrcmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[jdmrcmst] TO PUBLIC
    AS [dbo];

