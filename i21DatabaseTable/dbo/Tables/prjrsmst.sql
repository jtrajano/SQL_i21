CREATE TABLE [dbo].[prjrsmst] (
    [prjrs_stid]        CHAR (2)    NOT NULL,
    [prjrs_co_name]     CHAR (50)   NULL,
    [prjrs_co_addr]     CHAR (30)   NULL,
    [prjrs_co_addr2]    CHAR (30)   NULL,
    [prjrs_co_city]     CHAR (20)   NULL,
    [prjrs_co_state]    CHAR (2)    NULL,
    [prjrs_co_zip]      CHAR (10)   NULL,
    [prjrs_state_id]    CHAR (15)   NULL,
    [prjrs_sui_id]      CHAR (15)   NULL,
    [prjrs_user_id]     CHAR (16)   NULL,
    [prjrs_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prjrsmst] PRIMARY KEY NONCLUSTERED ([prjrs_stid] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprjrsmst0]
    ON [dbo].[prjrsmst]([prjrs_stid] ASC);

