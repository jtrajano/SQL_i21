CREATE TABLE [dbo].[cft6xmst] (
    [cft6x_pp_tax_code]  CHAR (20)   NOT NULL,
    [cft6x_ssi_tax_code] CHAR (3)    NULL,
    [cft6x_user_id]      CHAR (16)   NULL,
    [cft6x_user_rev_dt]  INT         NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cft6xmst] PRIMARY KEY NONCLUSTERED ([cft6x_pp_tax_code] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icft6xmst0]
    ON [dbo].[cft6xmst]([cft6x_pp_tax_code] ASC);

