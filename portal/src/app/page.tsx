import Link from 'next/link'

export default function LandingPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 py-6">
          <h1 className="text-3xl font-bold text-blue-900">Nile Export</h1>
          <p className="text-gray-600">بوابة الصادرات الرقمية</p>
        </div>
      </header>
      
      <main className="max-w-7xl mx-auto px-4 py-12">
        <section className="text-center mb-12">
          <h2 className="text-2xl font-semibold mb-4">دعم الصادرات الوطنية عالية الجودة</h2>
          <p className="text-lg text-gray-600">
            نحوّل مشاريعك من مصر إلى العالم بثقة وأمان
          </p>
        </section>

        <div className="grid md:grid-cols-3 gap-8">
          <Link href="/supplier" className="block p-6 bg-white rounded-lg shadow hover:shadow-md">
            <h3 className="text-xl font-semibold mb-2">مورّعوا؟</h3>
            <p className="text-gray-600">انضم إلينا كمورد لتصدير منتجاتك عالمياً</p>
          </Link>
          
          <Link href="/importer" className="block p-6 bg-white rounded-lg shadow hover:shadow-md">
            <h3 className="text-xl font-semibold mb-2">مستوردون؟</h3>
            <p className="text-gray-600">تتبع شحناتك وارفع المستندات بسهولة</p>
          </Link>
          
          <Link href="/rfq" className="block p-6 bg-white rounded-lg shadow hover:shadow-md">
            <h3 className="text-xl font-semibold mb-2">طلبات عروض الأسعار</h3>
            <p className="text-gray-600">انشر طلبك واحصل على أفضل العروض</p>
          </Link>
        </div>
      </main>
    </div>
  )
}