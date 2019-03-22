CREATE TABLE [dbo].[padivmst] (
    [padiv_cus_no]         CHAR (10)      NOT NULL,
    [padiv_stk_div_amt_1]  DECIMAL (7, 2) NULL,
    [padiv_stk_div_amt_2]  DECIMAL (7, 2) NULL,
    [padiv_stk_div_amt_3]  DECIMAL (7, 2) NULL,
    [padiv_stk_div_amt_4]  DECIMAL (7, 2) NULL,
    [padiv_stk_div_amt_5]  DECIMAL (7, 2) NULL,
    [padiv_stk_div_amt_6]  DECIMAL (7, 2) NULL,
    [padiv_stk_div_amt_7]  DECIMAL (7, 2) NULL,
    [padiv_stk_div_amt_8]  DECIMAL (7, 2) NULL,
    [padiv_stk_div_amt_9]  DECIMAL (7, 2) NULL,
    [padiv_stk_div_amt_10] DECIMAL (7, 2) NULL,
    [padiv_div_fwt_amt]    DECIMAL (9, 2) NULL,
    [padiv_div_chk_amt]    DECIMAL (9, 2) NULL,
    [padiv_div_chk_rev_dt] INT            NULL,
    [padiv_div_chk_no]     CHAR (8)       NULL,
    [padiv_div_trx_ind]    CHAR (1)       NULL,
    [A4GLIdentity]         NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_padivmst] PRIMARY KEY NONCLUSTERED ([padiv_cus_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipadivmst0]
    ON [dbo].[padivmst]([padiv_cus_no] ASC);

