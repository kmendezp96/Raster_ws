# Taller raster

## Propósito

Comprender algunos aspectos fundamentales del paradigma de rasterización.

## Tareas

Emplee coordenadas baricéntricas para:

1. Rasterizar un triángulo;
2. Implementar un algoritmo de anti-aliasing para sus aristas; y,
3. Hacer shading sobre su superficie.

Implemente la función ```triangleRaster()``` del sketch adjunto para tal efecto, requiere la librería [frames](https://github.com/VisualComputing/framesjs/releases).

## Integrantes

Máximo 3.

Complete la tabla:

| Integrante | github nick |
|------------|-------------|
| Yessica Chautá Insuasty | ykchautai |
| Andrés Sánchez Lemus | andfsanchezlem |
| Kevin Mendez Páez | kmendezp96 |

## Discusión

Describa los resultados obtenidos. Qué técnicas de anti-aliasing y shading se exploraron? Adjunte las referencias. Discuta las dificultades encontradas.

Basándonos en la técnica de antialiasing explicada en [esta](https://learnopengl.com/Advanced-OpenGL/Anti-Aliasing) página. Se toman como puntos iniciales los centros de cada pixel de acuerdo a la cuadrícula inicial y de acuerdo a las ecuaciones baricéntricas planteadas, ademas de la orientación del triangulo se define si se encuentran o no dentro del triángulo al que se le va a aplicar el efecto. Para reducir el aliasing utilizamos multisampling, para ello se evalúan 4 puntos dentro del mismo pixel distribuidos equitativamente para validar cuáles de ellos se encuentran dentro del triángulo y mejorar el rango tenido en cuenta para el perfilado del triángulo. Para colorear también se tiene en cuenta que cuántos más puntos haya dentro del triángulo, más intenso y claro será el color a mostrar.


Para el shading se usó [esta](https://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-rendering-a-triangle/barycentric-coordinates) referencia, con la cual se define cada vértice del triángulo como cada una de las coordenadas RGB y un punto dentro del triángulo, y usando las coordenadas baricéntricas se asignan los colores del resto de la imagen usando la fórmula general color = (u, v, 1-u-v) donde u y v son dos de las caras que forman las uniones de los vértices con el punto central.

Como algunas de las dificultades se tiene elegir cuáles son los métodos adecuados y las reglas que se deben seguir para obtener los mejores resultados a la hora de hacer un proceso de rasterización del triángulo. Entender cómo funcionan las coordenadas baricéntricas para realizar los cálculos y aplicarlas de manera conjunta al problema de anti-aliasing y shading, es importante identificar una técnica equilibrada de multisampling, la cual reduzca de manera evidente el aliasing de la imagen sin sacrificar el rendimiento del proceso, entre mayor sea el numero de puntos que se tomen de multisampling la imagen tendrá menor aliasing pero tardara mas tiempo rasterizando; finalmente aplicar la teoría a un problema real no se hace tan evidente.

## Entrega

* Modo de entrega: [Fork](https://help.github.com/articles/fork-a-repo/) la plantilla en las cuentas de los integrantes (de las que se tomará una al azar).
* Plazo: 1/4/18 a las 24h.
