using System.ComponentModel.DataAnnotations.Schema;
using System.Data.Entity.ModelConfiguration;

namespace iRely.Inventory.Model
{
    public class vyuICGetCustomerCurrencyMap : EntityTypeConfiguration<vyuICGetCustomerCurrency>
    {
        public vyuICGetCustomerCurrencyMap()
        {
            this.HasKey(t => t.intEntityId);

            this.ToTable("vyuICGetCustomerCurrency");
            this.Property(t => t.intEntityId).HasColumnName("intEntityId");
            this.Property(t => t.strCustomerNumber).HasColumnName("strCustomerNumber");
            this.Property(t => t.intCurrencyId).HasColumnName("intCurrencyId");
            this.Property(t => t.strCurrency).HasColumnName("strCurrency");
            this.Property(t => t.strDescription).HasColumnName("strDescription");
            this.Property(t => t.ysnSubCurrency).HasColumnName("ysnSubCurrency");
            this.Property(t => t.intMainCurrencyId).HasColumnName("intMainCurrencyId");
            this.Property(t => t.intCent).HasColumnName("intCent");
            this.Property(t => t.intDefaultCurrencyId).HasColumnName("intDefaultCurrencyId");
            this.Property(t => t.strDefaultCurrency).HasColumnName("strDefaultCurrency");
        }
    }
}
