using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class tblICItemNoteMap : EntityTypeConfiguration<tblICItemNote>
    {
        public tblICItemNoteMap()
        {
            // Primary Key
            this.HasKey(t => t.intItemNoteId);

            // Table & Column Mappings
            this.ToTable("tblICItemNote");
            this.Property(t => t.intItemNoteId).HasColumnName("intItemNoteId");
            this.Property(t => t.intItemId).HasColumnName("intItemId");
            this.Property(t => t.intItemLocationId).HasColumnName("intItemLocationId");
            this.Property(t => t.strCommentType).HasColumnName("strCommentType");
            this.Property(t => t.strComments).HasColumnName("strComments");
            this.Property(t => t.intSort).HasColumnName("intSort");

            this.HasOptional(p => p.tblICItemLocation)
                .WithMany(p => p.tblICItemNotes)
                .HasForeignKey(p => p.intItemLocationId);
        }
    }
}
