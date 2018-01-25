using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using PostSharp.Patterns.Diagnostics;
using PostSharp.Extensibility;

[assembly: Log("Detailed", AttributePriority = 1, AttributeTargetMemberAttributes = MulticastAttributes.Protected | MulticastAttributes.Internal | MulticastAttributes.Public)]
[assembly: Log("Detailed", AttributePriority = 2, AttributeExclude = true, AttributeTargetMembers = "regex:^get_|^set_|Dispose|.ctor")]
namespace iRely.Inventory.BusinessLayer
{
    public class AspectInfo
    {

    }
}