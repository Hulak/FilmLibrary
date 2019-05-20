using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LabFirst
{
    public class Rectangle
    {
        public double X, Y;
        public Rectangle()
        {
            X = 1;
            Y = 1;
        }
        public Rectangle(double x, double y)
        {
            X = x;
            Y = y;
        }
        public double Square()
        {
            return X * Y;
        }
    }
}
