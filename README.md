# 🧟 Arena Survival Game (Zombie Rush)

Un juego de supervivencia en arena 3D donde debes resistir oleadas infinitas de zombies usando diferentes armas y mejorando tus habilidades.

## 🎮 Descripción

Arena Survival Game es un juego de acción en tercera persona desarrollado en Godot 4.5, donde controlas a un superviviente que debe enfrentarse a hordas cada vez más peligrosas de enemigos zombies. El objetivo es sobrevivir el mayor tiempo posible mientras eliminas enemigos, subes de nivel y desbloqueas nuevas armas y mejoras.

## ✨ Características Principales

### 🔫 Sistema de Armas

- **Kunai**: Arma inicial de proyectiles con mejoras que aumentan cantidad, velocidad y penetración
- **Cuchilla Giratoria**: Arma de combate cuerpo a cuerpo que orbita alrededor del jugador
- **Bomba Explosiva**: Arma de área que se lanza hacia la posición del cursor

### 👾 Tipos de Enemigos

- **Zombies Normales**: Enemigos básicos con velocidad y resistencia estándar
- **Zombies Rápidos**: Más veloces pero menos resistentes
- **Minibosses**: Enemigos elite que aparecen en hordas especiales (2:30 y 5:00 minutos)

### 📈 Sistema de Progresión

- **Experiencia y Niveles**: Gana XP al eliminar enemigos y sube de nivel
- **Sistema de Mejoras**: Al subir de nivel, elige entre varias mejoras:
  - Desbloquear o mejorar armas (5 niveles por arma)
  - Aumentar velocidad de movimiento
  - Aumentar vida máxima
  - Regeneración de vida
  - Multiplicador de experiencia
  - Curación instantánea

### 🎯 Mecánicas de Juego

- **Combate Automático**: Las armas atacan automáticamente a los enemigos cercanos
- **Dificultad Progresiva**: Los enemigos se vuelven más rápidos, resistentes y numerosos con el tiempo
- **Hordas Especiales**: Eventos programados en el minuto 2:30 y 5:00 con oleadas intensas de enemigos
- **Sistema de Música Dinámica**: La música cambia durante las hordas para aumentar la tensión

## 🎮 Controles

- **W**: Mover hacia arriba
- **A**: Mover hacia la izquierda
- **S**: Mover hacia abajo
- **D**: Mover hacia la derecha
- **Ratón**: Apuntar dirección de ataque (el personaje mira hacia el cursor)

## 🛠️ Requisitos Técnicos

- **Motor**: Godot 4.5
- **Plataforma**: PC (Windows/Linux/Mac)
- **Características**: Forward Plus rendering

## 📁 Estructura del Proyecto

```
zombie-rush/
├── assets/           # Recursos visuales y audio
│   ├── Characters/   # Modelos de personajes
│   ├── Environment/  # Props del entorno
│   ├── Floor/        # Texturas del suelo
│   ├── audio/        # Efectos de sonido y música
│   └── weapons/      # Modelos de armas
├── scenes/           # Escenas de Godot
│   ├── entities/     # Jugador y enemigos
│   ├── main_levels/  # Escena principal del juego
│   ├── props/        # Objetos decorativos
│   └── weapons/      # Escenas de armas
├── scripts/          # Scripts GDScript
│   ├── core/         # Sistemas principales
│   ├── entities/     # Lógica de entidades
│   ├── ui/           # Interfaz de usuario
│   └── weapons/      # Comportamiento de armas
└── ui/               # Elementos de UI
```

## 🎯 Estrategias de Juego

1. **Primeros Niveles**: Enfócate en mejorar el Kunai para tener un buen DPS base
2. **Supervivencia**: Prioriza mejoras de velocidad y vida para sobrevivir más tiempo
3. **Hordas**: Prepárate para las hordas especiales en 2:30 y 5:00 minutos
4. **Variedad de Armas**: Desbloquea múltiples armas para cubrir diferentes rangos de combate
5. **Movilidad**: Mantente en movimiento constante, los enemigos siempre te perseguirán

## 🚀 Cómo Ejecutar

1. Instalar [Godot 4.5](https://godotengine.org/download)
2. Clonar o descargar este repositorio
3. Abrir el proyecto en Godot
4. Presionar F5 o hacer clic en "Play" para ejecutar el juego

## 📊 Progresión de Dificultad

| Tiempo | Intervalo Spawn | Enemigos Rápidos | HP Multiplicador | Eventos Especiales |
|--------|----------------|------------------|------------------|-------------------|
| 0-30s  | 1.5s           | 0%               | 1.0x             | -                 |
| 30-60s | 1.0s           | 20%              | 1.1x             | -                 |
| 1-2min | 0.8s           | 40%              | 1.3x             | -                 |
| 2-3min | 0.5s           | 50%              | 2.3x             | Horda 1 (2:30)    |
| 3-5min | 0.3s           | 80%              | 3.0x             | -                 |
| 5min+  | 0.1s           | 90%              | 3.0x+            | Horda 2 (5:00)    |

## 🎨 Créditos

Desarrollado con Godot Engine 4.5

## 📝 Licencia

Este proyecto está disponible como código abierto. Consulta el repositorio para más detalles.

---

¡Diviértete sobreviviendo a las hordas de zombies! 🧟‍♂️💀
