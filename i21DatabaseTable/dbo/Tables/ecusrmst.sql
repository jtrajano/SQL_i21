CREATE TABLE [dbo].[ecusrmst] (
    [ecusr_username]      CHAR (20)   NOT NULL,
    [ecusr_password]      CHAR (14)   NULL,
    [ecusr_name]          CHAR (50)   NOT NULL,
    [ecusr_email]         CHAR (64)   NULL,
    [ecusr_type_msn]      CHAR (1)    NULL,
    [ecusr_slsmn_id]      CHAR (3)    NULL,
    [ecusr_num_login]     INT         NULL,
    [ecusr_last_login_dt] INT         NULL,
    [ecusr_grain_view]    CHAR (1)    NULL,
    [ecusr_user_id]       CHAR (16)   NULL,
    [ecusr_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ecusrmst] PRIMARY KEY NONCLUSTERED ([ecusr_username] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iecusrmst0]
    ON [dbo].[ecusrmst]([ecusr_username] ASC);


GO
CREATE NONCLUSTERED INDEX [Iecusrmst1]
    ON [dbo].[ecusrmst]([ecusr_name] ASC);

