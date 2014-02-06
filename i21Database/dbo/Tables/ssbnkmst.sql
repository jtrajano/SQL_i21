CREATE TABLE [dbo].[ssbnkmst] (
    [ssbnk_code]              CHAR (4)        NOT NULL,
    [ssbnk_name]              CHAR (40)       NULL,
    [ssbnk_addr1]             CHAR (30)       NULL,
    [ssbnk_addr2]             CHAR (30)       NULL,
    [ssbnk_city]              CHAR (22)       NULL,
    [ssbnk_state]             CHAR (2)        NULL,
    [ssbnk_zip]               CHAR (10)       NULL,
    [ssbnk_transit_route]     INT             NULL,
    [ssbnk_email_addr]        CHAR (50)       NULL,
    [ssbnk_contact]           CHAR (40)       NULL,
    [ssbnk_phone]             CHAR (15)       NULL,
    [ssbnk_gl_acct]           DECIMAL (16, 8) NULL,
    [ssbnk_vnd_no]            CHAR (10)       NULL,
    [ssbnk_immed_origin]      CHAR (9)        NULL,
    [ssbnk_immed_destination] CHAR (9)        NULL,
    [ssbnk_user_id]           CHAR (16)       NULL,
    [ssbnk_user_rev_dt]       INT             NULL,
    [A4GLIdentity]            NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ssbnkmst] PRIMARY KEY NONCLUSTERED ([ssbnk_code] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Issbnkmst0]
    ON [dbo].[ssbnkmst]([ssbnk_code] ASC);

