using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp1
{
    class Program
    {


        static void Main(string[] args)
        {
            Console.WriteLine("Hello World!\n");
            Rectangle first = new Rectangle();
            Rectangle second = new Rectangle(2, 5);
            Console.WriteLine("First square: " + first.Square());
            Console.WriteLine("Second square: " + second.Square());
            Console.ReadKey();
        }
    }
}
