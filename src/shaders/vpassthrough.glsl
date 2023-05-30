#version 330

in vec3 vertex;
in vec3 normal; // normales

uniform mat4 modelViewProjMat;
uniform vec3 color;
uniform vec3 lightPos; // posición de la luz
uniform float intensity; // intensidad de la luz ambiental
uniform float indirectIntensity; // intensidad de la luz indirecta
uniform float steepness; // pendiente
uniform float waveLength; // separación entre olas
uniform float delta_time; // tiempo transcurrido desde la última llamada al shader
uniform vec3 direction; // dirección

out vec4 vertColor;

void main()
{
    // Cálculo de la dirección de la ola en el plano xz
    vec3 directionXZ = normalize(vec3(direction.x, 0.0, direction.z));

    // Cálculo de la constante k
    float k = 2.0 * 3.14159265358979323846 / waveLength;

    // Cálculo de la variable f
    float f = k * (dot(directionXZ, vertex) - delta_time * sqrt(9.8 / k));

    // Cálculo del vector de transformación
    vec3 transformVector = vec3(directionXZ.x * cos(f), sin(f), directionXZ.z * cos(f));
    transformVector = transformVector * (steepness / k);

    // Aplicación de la transformación al vértice
    vec3 transformedVertex = vertex + transformVector;

    // Cálculo de la normal
    vec3 tangent = vec3(1.0 - pow(directionXZ.x, 2.0), 0.0, -directionXZ.x) / length(vec3(1.0 - pow(directionXZ.x, 2.0), 0.0, -directionXZ.x));
    vec3 binormal = cross(normalize(vec3(0.0, 1.0, 0.0)), tangent);
    vec3 normalVector = normalize(cross(tangent, binormal));

    // Cálculo del color
    vec3 lightDirection = normalize(lightPos - transformedVertex);
    vec3 materialDiffuseColor = color.rgb;

    // Difuso
    vec3 diffuseColor = max(dot(normalVector, lightDirection), 0.0) * materialDiffuseColor;

    // Ambiente
    vec3 ambientColor = intensity * materialDiffuseColor;

    // Indirecta
    vec3 indirectLight = vec3(0.0);
    if (indirectIntensity > 0.0) {
        vec3 lightPosition = vec3(0, 0, 0); // esta es la posición de la luz, en el centro sin elevarse para las olas
        vec3 lightDirection = normalize(lightPosition - transformedVertex);
        vec3 indirectNormalVector = normalize(cross(tangent, binormal));
        indirectLight = indirectIntensity * materialDiffuseColor * max(dot(indirectNormalVector, lightDirection), 0.0);
    }

    // Suma de todos los componentes
    vec3 finalColor = ambientColor + diffuseColor + indirectLight;

    // Asignación de los valores de salida
    vertColor = vec4(finalColor, 1.0);
    gl_Position = modelViewProjMat * vec4(transformedVertex, 1.0);
}
