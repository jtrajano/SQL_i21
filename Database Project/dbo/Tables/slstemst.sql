CREATE TABLE [dbo].[slstemst] (
    [slste_id]          CHAR (2)    NOT NULL,
    [slste_cnty_name]   CHAR (15)   NOT NULL,
    [slste_st_code]     CHAR (2)    NOT NULL,
    [slste_cnty_code]   SMALLINT    NOT NULL,
    [slste_area_desc]   CHAR (4)    NULL,
    [slste_user_id]     CHAR (16)   NULL,
    [slste_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_slstemst] PRIMARY KEY NONCLUSTERED ([slste_id] ASC, [slste_cnty_name] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Islstemst0]
    ON [dbo].[slstemst]([slste_id] ASC, [slste_cnty_name] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Islstemst1]
    ON [dbo].[slstemst]([slste_st_code] ASC, [slste_cnty_code] ASC);

