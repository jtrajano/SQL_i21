using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace iRely.Inventory.Test.Import
{
    public static class FakeCsvGenerator
    {
        public static TextReader CreateCsvReader()
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("Code,Description");
            sb.AppendLine("000-1,Description for 000-1");
            sb.AppendLine("000-1,Description for 000-1");
            sb.AppendLine("000-2,Description for 000-1");

            TextReader reader = new StringReader(sb.ToString());
            return reader;
        }
    }

    public abstract class FakeCsvBuilder
    {
        public abstract StringBuilder BuildUnique();
        public abstract StringBuilder BuildWithDuplicate();
        public abstract StringBuilder BuildWithEmpty();
        public abstract StringBuilder BuildWithInvalid();
        public abstract StringBuilder BuildEmptyWithHeaders();
        public abstract StringBuilder BuildEmpty();
    }

    public class FakeBrandBuilder : FakeCsvBuilder
    {
        public override StringBuilder BuildUnique()
        {
            var sb = new StringBuilder();
            sb.AppendLine("Brand Code, Brand Name, Manufacturer");
            sb.AppendLine("Brand 1, Brand 1, Manufacturer");
            sb.AppendLine("Brand 2, Brand 2, Manufacturer");
            sb.AppendLine("Brand 3, Brand 3, Manufacturer");
            sb.AppendLine("Brand 4, Brand 4, Manufacturer");
            sb.AppendLine("Brand 5, Brand 5, Manufacturer");
            sb.AppendLine("Brand 6, Brand 6, Manufacturer");
            return sb;
        }

        public override StringBuilder BuildWithDuplicate()
        {
            var sb = new StringBuilder();
            sb.AppendLine("Brand Code, Brand Name, Manufacturer");
            sb.AppendLine("Brand 1, Brand 1, Manufacturer");
            sb.AppendLine("Brand 2, Brand 2, Manufacturer");
            sb.AppendLine("Brand 1, Brand 1, Manufacturer");
            sb.AppendLine("Brand 4, Brand 4, Manufacturer");
            sb.AppendLine("Brand 5, Brand 5, Manufacturer");
            sb.AppendLine("Brand 6, Brand 6, Manufacturer");
            return sb;
        }

        public override StringBuilder BuildWithEmpty()
        {
            var sb = new StringBuilder();
            sb.AppendLine("Brand Code, Brand Name, Manufacturer");
            sb.AppendLine("Brand 1, Brand 1, Manufacturer");
            sb.AppendLine("Brand 2, Brand 2, Manufacturer");
            sb.AppendLine(",,");
            sb.AppendLine("Brand 4, Brand 4, Manufacturer");
            sb.AppendLine("Brand 5, Brand 5, Manufacturer");
            sb.AppendLine("Brand 6, Brand 6, Manufacturer");
            return sb;
        }

        public override StringBuilder BuildWithInvalid()
        {
            var sb = new StringBuilder();
            sb.AppendLine("Brand Code, Brand Name, Manufacturer");
            sb.AppendLine("Brand 1, Brand 1, Manufacturer");
            sb.AppendLine("Brand 2, Brand 2, Manufacturer");
            sb.AppendLine("Brand 3, Brand 3, Mafacturer");
            sb.AppendLine("Brand 4, Brand 4, Manufacturer");
            sb.AppendLine("Brand 5, Brand 5, Manufacturer");
            sb.AppendLine("Brand 6, Brand 6, Manufacturer");
            return sb;
        }

        public override StringBuilder BuildEmptyWithHeaders()
        {
            var sb = new StringBuilder();
            sb.AppendLine("Brand Code, Brand Name, Manufacturer");
            return sb;
        }

        public override StringBuilder BuildEmpty()
        {
            var sb = new StringBuilder();
            return sb;
        }
    }

    public class FakeCsvDirector
    {
        private readonly FakeCsvBuilder builder;

        public FakeCsvDirector(FakeCsvBuilder builder)
        {
            this.builder = builder;
        }

        public StringBuilder BuildUnique() { return builder.BuildUnique(); }
        public StringBuilder BuildWithDuplicate() { return builder.BuildWithDuplicate(); }
        public StringBuilder BuildWithEmpty() { return builder.BuildWithEmpty(); }
        public StringBuilder BuildWithInvalid() { return builder.BuildWithInvalid(); }
        public StringBuilder BuildEmptyWithHeaders() { return builder.BuildEmptyWithHeaders(); }
        public StringBuilder BuildEmpty() { return builder.BuildEmpty(); }
    }
}
