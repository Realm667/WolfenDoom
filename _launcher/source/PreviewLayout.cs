using System;
using System.Drawing;

namespace BladeOfAgonyLauncher
{
    internal static class PreviewLayout
    {
        internal static Rectangle Fit16By9(Size available)
        {
            if (available.Width < 1 || available.Height < 1) {
                return Rectangle.Empty;
            }
            int width = available.Width;
            int height = (int)Math.Round(width * 9d / 16d);
            if (height > available.Height) {
                height = available.Height;
                width = (int)Math.Round(height * 16d / 9d);
            }
            int left = Math.Max(0, (available.Width - width) / 2);
            int top = Math.Max(0, available.Height - height);
            return new Rectangle(left, top, Math.Max(0, width), Math.Max(0, height));
        }

        internal static int HeightFor16By9Width(int width)
        {
            return width < 1 ? 0 : (int)Math.Round(width * 9d / 16d);
        }

        internal static RectangleF CoverSource(Size image, Size target)
        {
            if (image.Width < 1 || image.Height < 1 || target.Width < 1 || target.Height < 1) {
                return RectangleF.Empty;
            }
            float targetRatio = target.Width / (float)target.Height;
            float imageRatio = image.Width / (float)image.Height;
            if (imageRatio > targetRatio) {
                float sourceWidth = image.Height * targetRatio;
                return new RectangleF((image.Width - sourceWidth) / 2f, 0, sourceWidth, image.Height);
            }
            float sourceHeight = image.Width / targetRatio;
            return new RectangleF(0, (image.Height - sourceHeight) / 2f, image.Width, sourceHeight);
        }

        internal static bool SelfTest()
        {
            Rectangle landscapeHost = Fit16By9(new Size(640, 400));
            Rectangle portraitHost = Fit16By9(new Size(320, 500));
            int fullWidthHeight = HeightFor16By9Width(640);
            RectangleF wideSource = CoverSource(new Size(1920, 800), new Size(640, 360));
            RectangleF tallSource = CoverSource(new Size(800, 1200), new Size(640, 360));

            return fullWidthHeight == 360 &&
                   Is16By9(new Size(640, fullWidthHeight)) &&
                   Is16By9(landscapeHost.Size) &&
                   Is16By9(portraitHost.Size) &&
                   NearlyEqual(wideSource.Width / wideSource.Height, 16f / 9f) &&
                   NearlyEqual(tallSource.Width / tallSource.Height, 16f / 9f) &&
                   wideSource.Width < 1920 &&
                   tallSource.Height < 1200;
        }

        private static bool Is16By9(Size size)
        {
            return size.Width > 0 && size.Height > 0 &&
                   Math.Abs(size.Width / (double)size.Height - 16d / 9d) < 0.01d;
        }

        private static bool NearlyEqual(float left, float right)
        {
            return Math.Abs(left - right) < 0.001f;
        }
    }
}
