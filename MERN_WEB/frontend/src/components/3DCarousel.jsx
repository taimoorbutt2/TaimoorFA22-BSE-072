import React, { useEffect, useRef } from 'react'

const ThreeDCarousel = () => {
  const carouselRef = useRef(null)

  // Beautiful artisan/craft images for the carousel
  const images = [
    {
      src: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=900&h=700&fit=crop',
      alt: 'Handcrafted Wooden Art',
      category: 'Woodworking'
    },
    {
      src: 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?w=900&h=700&fit=crop',
      alt: 'Handmade Jewelry',
      category: 'Jewelry'
    },
    {
      src: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=900&h=700&fit=crop',
      alt: 'Ceramic Pottery',
      category: 'Pottery'
    },
    {
      src: 'https://images.unsplash.com/photo-1520903920243-00d872a2d1c9?w=900&h=700&fit=crop',
      alt: 'Textile Weaving',
      category: 'Textiles'
    },
    {
      src: 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=900&h=700&fit=crop',
      alt: 'Handmade Soap',
      category: 'Bath & Body'
    },
    {
      src: 'https://images.unsplash.com/photo-1513475382585-d06e58bcb0e0?w=900&h=700&fit=crop',
      alt: 'Leather Crafting',
      category: 'Leather'
    },
    {
      src: 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=900&h=700&fit=crop',
      alt: 'Glass Blowing',
      category: 'Glass'
    },
    {
      src: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=900&h=700&fit=crop',
      alt: 'Metal Smithing',
      category: 'Metalwork'
    }
  ]

  useEffect(() => {
    const carousel = carouselRef.current
    if (!carousel) return

    let currentRotation = 0
    const radius = 750 // Increased radius for bigger images
    const totalImages = images.length
    const angleStep = (2 * Math.PI) / totalImages

    const updateCarousel = () => {
      currentRotation += 0.0015 // Slower rotation for better visibility of bigger images
      
      images.forEach((_, index) => {
        const img = carousel.children[index]
        if (img) {
          const angle = currentRotation + (index * angleStep)
          const x = Math.sin(angle) * radius
          const z = Math.cos(angle) * radius
          const rotation = (angle * 180) / Math.PI
          
          // Apply 3D transforms
          img.style.transform = `translate3d(${x}px, 0px, ${z}px) rotateY(${rotation}deg)`
          
          // Add depth effect with opacity and scale
          const depth = (z + radius) / (2 * radius)
          img.style.opacity = 0.6 + (depth * 0.4)
          img.style.scale = 0.85 + (depth * 0.15)
        }
      })
      
      requestAnimationFrame(updateCarousel)
    }

    updateCarousel()

    return () => {
      // Cleanup if needed
    }
  }, [images.length])

  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none">
      <div 
        ref={carouselRef}
        className="relative w-full h-full flex items-center justify-center"
        style={{ perspective: '1800px' }}
      >
        {images.map((image, index) => (
          <div
            key={index}
            className="absolute w-96 h-72 rounded-xl overflow-hidden shadow-2xl transition-all duration-1000 ease-out"
            style={{
              transformOrigin: 'center center',
              transform: `translate3d(0px, 0px, 0px) rotateY(0deg)`,
              backfaceVisibility: 'hidden'
            }}
          >
            <img
              src={image.src}
              alt={image.alt}
              className="w-full h-full object-cover"
              onError={(e) => {
                e.target.src = 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=900&h=700&fit=crop'
              }}
            />
            <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/80 to-transparent p-4">
              <p className="text-white text-base font-semibold">{image.category}</p>
            </div>
          </div>
        ))}
      </div>
      
      {/* Floating particles for extra visual effect */}
      <div className="absolute inset-0">
        {[...Array(25)].map((_, i) => (
          <div
            key={i}
            className="absolute w-2.5 h-2.5 bg-white/30 rounded-full animate-pulse"
            style={{
              left: `${Math.random() * 100}%`,
              top: `${Math.random() * 100}%`,
              animationDelay: `${Math.random() * 2}s`,
              animationDuration: `${2 + Math.random() * 2}s`
            }}
          />
        ))}
      </div>
    </div>
  )
}

export default ThreeDCarousel
