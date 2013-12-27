CREATE TABLE [dbo].[agsccmst] (
    [agscc_cus_no]    CHAR (10)       NOT NULL,
    [agscc_class]     CHAR (3)        NOT NULL,
    [agscc_per_ty_1]  DECIMAL (11, 2) NULL,
    [agscc_per_ty_2]  DECIMAL (11, 2) NULL,
    [agscc_per_ty_3]  DECIMAL (11, 2) NULL,
    [agscc_per_ty_4]  DECIMAL (11, 2) NULL,
    [agscc_per_ty_5]  DECIMAL (11, 2) NULL,
    [agscc_per_ty_6]  DECIMAL (11, 2) NULL,
    [agscc_per_ty_7]  DECIMAL (11, 2) NULL,
    [agscc_per_ty_8]  DECIMAL (11, 2) NULL,
    [agscc_per_ty_9]  DECIMAL (11, 2) NULL,
    [agscc_per_ty_10] DECIMAL (11, 2) NULL,
    [agscc_per_ty_11] DECIMAL (11, 2) NULL,
    [agscc_per_ty_12] DECIMAL (11, 2) NULL,
    [agscc_per_ly_1]  DECIMAL (11, 2) NULL,
    [agscc_per_ly_2]  DECIMAL (11, 2) NULL,
    [agscc_per_ly_3]  DECIMAL (11, 2) NULL,
    [agscc_per_ly_4]  DECIMAL (11, 2) NULL,
    [agscc_per_ly_5]  DECIMAL (11, 2) NULL,
    [agscc_per_ly_6]  DECIMAL (11, 2) NULL,
    [agscc_per_ly_7]  DECIMAL (11, 2) NULL,
    [agscc_per_ly_8]  DECIMAL (11, 2) NULL,
    [agscc_per_ly_9]  DECIMAL (11, 2) NULL,
    [agscc_per_ly_10] DECIMAL (11, 2) NULL,
    [agscc_per_ly_11] DECIMAL (11, 2) NULL,
    [agscc_per_ly_12] DECIMAL (11, 2) NULL,
    [A4GLIdentity]    NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agsccmst] PRIMARY KEY NONCLUSTERED ([agscc_cus_no] ASC, [agscc_class] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagsccmst0]
    ON [dbo].[agsccmst]([agscc_cus_no] ASC, [agscc_class] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agsccmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agsccmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agsccmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agsccmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agsccmst] TO PUBLIC
    AS [dbo];

