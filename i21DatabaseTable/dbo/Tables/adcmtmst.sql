CREATE TABLE [dbo].[adcmtmst] (
    [adcmt_cus_no]      CHAR (10)   NOT NULL,
    [adcmt_itm_no]      CHAR (13)   NOT NULL,
    [adcmt_tank_no]     CHAR (4)    NOT NULL,
    [adcmt_seq_no]      SMALLINT    NOT NULL,
    [adcmt_data]        CHAR (80)   NULL,
    [adcmt_user_id]     CHAR (16)   NULL,
    [adcmt_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_adcmtmst] PRIMARY KEY NONCLUSTERED ([adcmt_cus_no] ASC, [adcmt_itm_no] ASC, [adcmt_tank_no] ASC, [adcmt_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iadcmtmst0]
    ON [dbo].[adcmtmst]([adcmt_cus_no] ASC, [adcmt_itm_no] ASC, [adcmt_tank_no] ASC, [adcmt_seq_no] ASC);

