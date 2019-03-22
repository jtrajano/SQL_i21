CREATE TABLE [dbo].[coefdmst] (
    [coefd_contact_id]   CHAR (20)   NOT NULL,
    [coefd_eform_type]   CHAR (3)    NOT NULL,
    [coefd_loc_no]       CHAR (3)    NOT NULL,
    [coefd_cus_no]       CHAR (10)   NOT NULL,
    [coefd_contact_code] CHAR (20)   NOT NULL,
    [coefd_vnd_no]       CHAR (10)   NOT NULL,
    [coefd_program_name] CHAR (12)   NULL,
    [coefd_by_mail]      CHAR (1)    NULL,
    [coefd_by_fax]       CHAR (1)    NULL,
    [coefd_by_email]     CHAR (1)    NULL,
    [coefd_timestamp]    CHAR (19)   NULL,
    [coefd_user_id]      CHAR (16)   NULL,
    [coefd_user_rev_dt]  INT         NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_coefdmst] PRIMARY KEY NONCLUSTERED ([coefd_contact_id] ASC, [coefd_eform_type] ASC, [coefd_loc_no] ASC, [coefd_cus_no] ASC, [coefd_contact_code] ASC, [coefd_vnd_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icoefdmst0]
    ON [dbo].[coefdmst]([coefd_contact_id] ASC, [coefd_eform_type] ASC, [coefd_loc_no] ASC, [coefd_cus_no] ASC, [coefd_contact_code] ASC, [coefd_vnd_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefdmst1]
    ON [dbo].[coefdmst]([coefd_cus_no] ASC, [coefd_eform_type] ASC, [coefd_loc_no] ASC, [coefd_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefdmst2]
    ON [dbo].[coefdmst]([coefd_cus_no] ASC, [coefd_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefdmst3]
    ON [dbo].[coefdmst]([coefd_cus_no] ASC, [coefd_contact_id] ASC, [coefd_eform_type] ASC, [coefd_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefdmst4]
    ON [dbo].[coefdmst]([coefd_contact_code] ASC, [coefd_eform_type] ASC, [coefd_loc_no] ASC, [coefd_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefdmst5]
    ON [dbo].[coefdmst]([coefd_contact_code] ASC, [coefd_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefdmst6]
    ON [dbo].[coefdmst]([coefd_contact_code] ASC, [coefd_contact_id] ASC, [coefd_eform_type] ASC, [coefd_loc_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefdmst7]
    ON [dbo].[coefdmst]([coefd_vnd_no] ASC, [coefd_eform_type] ASC, [coefd_loc_no] ASC, [coefd_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefdmst8]
    ON [dbo].[coefdmst]([coefd_vnd_no] ASC, [coefd_contact_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Icoefdmst9]
    ON [dbo].[coefdmst]([coefd_vnd_no] ASC, [coefd_contact_id] ASC, [coefd_eform_type] ASC, [coefd_loc_no] ASC);

