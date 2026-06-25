import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'Nile Export - Digital Export Gateway',
  description: 'Egyptian LLC supporting high-quality national exports',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ar" dir="rtl">
      <body>{children}</body>
    </html>
  )
}