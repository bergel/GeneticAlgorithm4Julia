#=
    Genetic algorithm is a search algorithm, which a computational
    metaphor on how natural evolution happen. It is useful to solve
    a wide range of problems that are hard to solve using brute-force.
=#

using Pkg
# Pkg.add("Test")
using Test
using Random

# To make everything reproducible
Random.seed!(42)

# Create a gene value
function createGene() 
    return floor(Int, rand() * 10)
end

# Create an individual
function createIndividual() 
    return [createGene() for i in 1:5]
end

# Create population
function createPopulation() 
    return [createIndividual() for i in 1:10]
end

# Genetic operation: Crossover
function crossover(ind1, ind2)
    size = length(ind1)
    randomIndex = floor(Int64, rand() * size)
    return crossoverAtIndex(ind1, ind2, randomIndex)
end

function crossoverAtIndex(ind1, ind2, index)
    return vcat(ind1[1:index], ind2[index + 1:length(ind2)])
end

@test crossoverAtIndex([1, 2, 3, 4], [10, 20, 30, 40], 2) == [1, 2, 30, 40]
@test crossoverAtIndex([1, 2, 3, 4], [10, 20, 30, 40], 1) == [1, 20, 30, 40]
@test crossoverAtIndex([1, 2, 3, 4], [10, 20, 30, 40], 0) == [10, 20, 30, 40]
@test crossoverAtIndex([1, 2, 3, 4], [10, 20, 30, 40], 4) == [1, 2, 3, 4]

# Genetic operation: Mutation
function mutate(ind)
    size = length(ind)
    randomIndex = floor(Int64, rand() * size + 1)
    return mutateAtIndex(ind, randomIndex)
end

function mutateAtIndex(ind, index)
    t = copy(ind)
    t[index] = createGene()
    return t
end

# Return true if the two individuals are the same, expect with a mutation at a particular index
function checkIfSimilar(ind1, ind2)
    pairs = collect(zip(ind1, ind2))
    # the predicate is the same than t -> first(t) == last(t)
    allIdentical = filter(((a, b),) -> a == b, pairs)
    allDifferent = filter(((a, b),) -> a != b, pairs)
    oneDiff = length(allDifferent) == 1
    allTheRestTheSame = length(allIdentical) == (length(ind1) - 1)
    return oneDiff && allTheRestTheSame
end
@test checkIfSimilar([1, 2, 3, 4], mutateAtIndex([1, 2, 3, 4], 2))
@test checkIfSimilar([1, 2, 3, 4], mutateAtIndex([1, 2, 3, 4], 1))
@test checkIfSimilar([1, 2, 3, 4], mutateAtIndex([1, 2, 3, 4], 4))


# Fitness function
function fitness(ind)
    solution = 1:5
    allDifferent = filter(((a,b),) -> a != b, collect(zip(solution, ind)))
    return length(allDifferent)
end

@test fitness([3, 2, 1, 4, 5]) == 2
@test fitness(reverse(collect(1:5))) == 4
@test fitness(1:5) == 0

function bestFitnessOf(population)
    return maximum(map(fitness, population))
end 

# Pick best individual
function pickBestIndividual(population)
    indexMaxFitness = argmin(map(fitness, population))
    bestIndividual = population[indexMaxFitness]
    return bestIndividual
end

@test pickBestIndividual([[3, 2, 1, 4, 5], reverse(collect(1:5)), 1:5]) == 1:5
@test pickBestIndividual([[3, 2, 1, 4, 5], reverse(collect(1:5))]) == [3, 2, 1, 4, 5]


# Selection using the tournament of size k
# Assume that the smallest fitness is the best
function selectIndividual(population; k=5)
    populationSize = length(population)
    selectedIndividuals = []
    for tmp in 1:k
        anInd = population[floor(Int64, rand()*populationSize) + 1]
        push!(selectedIndividuals, anInd)
    end
    return pickBestIndividual(selectedIndividuals)
end

@test selectIndividual([[3, 2, 1, 4, 5], reverse(collect(1:5)), 1:5]) == 1:5
@test selectIndividual([[3, 2, 1, 4, 5], reverse(collect(1:5))]) == [3, 2, 1, 4, 5]

# We are now ready to run the algorithm
function run(;maxNumberOfIterations=10, probMutation=0.2)
    population = createPopulation()
    numberOfIndividuals = length(population)
    fitnesses = []
    for iteration in 1:maxNumberOfIterations
        newPopulation = []
        for it in 1:numberOfIndividuals
            ind1 = selectIndividual(population)
            ind2 = selectIndividual(population)
            newIndividual = crossover(ind1, ind2)
            if (rand() <= probMutation) 
                newIndividual = mutate(newIndividual)
            end
            push!(newPopulation, newIndividual)
        end
        population = newPopulation
        push!(fitnesses, bestFitnessOf(population))
    end
    return pickBestIndividual(population), fitnesses
end

run(maxNumberOfIterations=40)
