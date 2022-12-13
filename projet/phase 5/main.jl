include("Reconstruct.jl")

const PROJECT_PATH = "/Users/luisrojo/Library/CloudStorage/OneDrive-usach.cl/PhD/Courses_Polymtl/OR Algorithms/Laboratory/ImageReconstruction/projet"
filename = "blue-hour-paris"
picture = load(PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png")

# algorithm parameterization
const TOUR_ALGO = "HK"
const READ = "pre"
const STEP = [1.0, 150.0]
const ADAPT = true
const RAND_ROOT = true
const TL = 300
const ALGO = kruskal

# perform the procedure
reconstruct(filename, TOUR_ALGO, READ, STEP, ADAPT, RAND_ROOT, TL, ALGO)