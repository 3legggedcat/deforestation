using Godot;
using System.Collections.Generic;

public partial class Boid : CharacterBody2D
{
	// Adjustable in the Inspector
	[Export] public float MaxSpeed = 300.0f;
	[Export] public float SeparationWeight = 1.5f;
	[Export] public float AlignmentWeight = 1.0f;
	[Export] public float CohesionWeight = 1.0f;
	[Export] public float FollowWeight = 2.0f;
	[Export] public float FollowRadius = 150.0f;
	[Export] public float SeparationDistance = 50.0f;
	[Export] public float TurnSpeed = 3.0f;
	
	private List<Boid> _neighbors = new();
	private Area2D _detectionArea;
	private CharacterBody2D _target;

	public override void _Ready()
	{
		_detectionArea = GetNode<Area2D>("DetectionArea");
		_detectionArea.BodyEntered += OnBodyEntered;
		_detectionArea.BodyExited += OnBodyExited;
		
		// Random starting position
		var viewportRect = GetViewportRect();
		var randomX = GD.Randf() * viewportRect.Size.X;
		var randomY = GD.Randf() * viewportRect.Size.Y;
		Position = new Vector2(randomX, randomY);
		
		// Random initial velocity
		var randomAngle = GD.Randf() * Mathf.Pi * 2;
		var randomVelocity = new Vector2(Mathf.Cos(randomAngle), Mathf.Sin(randomAngle)) * MaxSpeed;
		Velocity = randomVelocity;
		
		// Face movement direction
		if (Velocity.LengthSquared() > 0.01f)
			LookAt(Position + Velocity);
	}

	public void SetTarget(CharacterBody2D target)
	{
		_target = target;
	}

	public override void _PhysicsProcess(double delta)
	{
		// Calculate steering forces
		Vector2 separation = Separation() * SeparationWeight;
		Vector2 alignment = Alignment() * AlignmentWeight;
		Vector2 cohesion = Cohesion() * CohesionWeight;
		Vector2 follow = FollowTarget() * FollowWeight;
		
		// Combine all forces
		Vector2 acceleration = separation + alignment + cohesion + follow;
		
		// Smooth steering with proper delta-independent interpolation
		if (acceleration.LengthSquared() > 0.01f)
		{
			Vector2 desiredVelocity = acceleration.Normalized() * MaxSpeed;
			Velocity = Velocity.Lerp(desiredVelocity, TurnSpeed * (float)delta);
		}
		
		// Clamp velocity to max speed
		Velocity = Velocity.LimitLength(MaxSpeed);
		
		MoveAndSlide();
		WrapAroundScreen();
		
		// Face movement direction
		if (Velocity.LengthSquared() > 0.01f)
			LookAt(Position + Velocity);
	}

	private void OnBodyEntered(Node2D body)
	{
		if (body is Boid boid && body != this)
		{
			_neighbors.Add(boid);
		}
	}

	private void OnBodyExited(Node2D body)
	{
		if (body is Boid boid && body != this)
		{
			_neighbors.Remove(boid);
		}
	}

	// Rule 1: Separation—Avoid crowding neighbors
	private Vector2 Separation()
	{
		if (_neighbors.Count == 0) return Vector2.Zero;

		Vector2 steer = Vector2.Zero;
		foreach (var neighbor in _neighbors)
		{
			Vector2 diff = Position - neighbor.Position;
			float distance = diff.Length();
			
			// Closer neighbors have stronger influence
			if (distance < SeparationDistance && distance > 0)
				steer += diff.Normalized() / distance;
		}
		
		return steer.LengthSquared() > 0 ? steer.Normalized() : Vector2.Zero;
	}

	// Rule 2: Alignment—Steer towards the average heading of neighbors
	private Vector2 Alignment()
	{
		if (_neighbors.Count == 0) return Vector2.Zero;

		Vector2 averageVelocity = Vector2.Zero;
		foreach (var neighbor in _neighbors)
		{
			averageVelocity += neighbor.Velocity;
		}
		averageVelocity /= _neighbors.Count;
		
		return averageVelocity.LengthSquared() > 0 ? averageVelocity.Normalized() : Vector2.Zero;
	}

	// Rule 3: Cohesion—Move towards the average position of neighbors
	private Vector2 Cohesion()
	{
		if (_neighbors.Count == 0) return Vector2.Zero;

		Vector2 centerOfMass = Vector2.Zero;
		foreach (var neighbor in _neighbors)
		{
			centerOfMass += neighbor.Position;
		}
		centerOfMass /= _neighbors.Count;

		Vector2 directionToCenter = centerOfMass - Position;
		return directionToCenter.LengthSquared() > 0 ? directionToCenter.Normalized() : Vector2.Zero;
	}
	
	// Rule 4: Follow the target (NPC)
	private Vector2 FollowTarget()
	{
		if (_target == null || !IsInstanceValid(_target))
			return Vector2.Zero;
		
		float distanceToTarget = Position.DistanceTo(_target.GlobalPosition);
		
		// If already close enough to target, reduce following force
		if (distanceToTarget < FollowRadius)
		{
			// Gentle orbit behavior
			return Vector2.Zero;
		}
		
		// Move towards target
		Vector2 directionToTarget = (_target.GlobalPosition - Position).Normalized();
		return directionToTarget;
	}
	
	private void WrapAroundScreen()
	{
		var viewportRect = GetViewportRect();
		var pos = Position;
		
		if (pos.X < 0) pos.X = viewportRect.Size.X;
		if (pos.X > viewportRect.Size.X) pos.X = 0;
		if (pos.Y < 0) pos.Y = viewportRect.Size.Y;
		if (pos.Y > viewportRect.Size.Y) pos.Y = 0;
		
		Position = pos;
	}
}
