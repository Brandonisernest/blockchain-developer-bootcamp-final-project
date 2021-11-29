# Design patterns used

## Inheritance and Interfaces

- `SecretSanta` contract inherits `SecretSantaInterface`, which inherits from `EventsInterface` for organization and clean re-usability

## Optimizing Gas

- Reduced the use of loops by using linked-list method for managing sequential addresses

## Access Control Design Patterns

- Mimicked Ownable design pattern by having certain functions restricted to the owner of the contract (Santa).
