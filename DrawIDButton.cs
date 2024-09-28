using System;
using System.Collections.Generic;
using System.Threading;
using Godot;
using Timer = Godot.Timer;

namespace 来抽学号;

public partial class DrawIDButton : Button
{
	private Timer timer;
	private Timer timerText;
	private Timer timerResetText;
	private Timer splashTimer;
	private static List<int> numbers = new List<int> {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38};
	private List<int> usedNumbers = new List<int>(numbers);

	public override void _Ready()
	{
		timer = new Timer();
		AddChild(timer);
		timer.WaitTime = 1;
		timer.Connect("timeout", Callable.From(CloseWindow));
		timer.OneShot = true;

		timerText = new Timer();
		AddChild(timerText);
		timerText.WaitTime = 3;
		timerText.Connect("timeout", Callable.From(CleanText));
		timerText.OneShot = true;

		timerResetText = new Timer();
		AddChild(timerResetText);
		timerResetText.WaitTime = 1;
		timerResetText.Connect("timeout", Callable.From(CleanResetText));
		timerResetText.OneShot = true;

		splashTimer = new Timer();
		AddChild(splashTimer);
		splashTimer.WaitTime = 2;
		splashTimer.Connect("timeout", Callable.From(CloseSplashText));
		splashTimer.OneShot = true;
		GetNode<Label>("Label").Text = " 点击按钮抽取学号";
		splashTimer.Start();
	}

	public void _Process(float delta)
	{
	}

	private void ShuffleArray(List<int> array)
	{
		Random rand = new Random();
		for (int i = array.Count - 1; i > 0; i--)
		{
			int j = rand.Next(i + 1);
			int temp = array[i];
			array[i] = array[j];
			array[j] = temp;
		}
	}

	private void GenId(List<int> this_usedNumbers)
	{
		if (this_usedNumbers.Count > 0)
		{
			ShuffleArray(this_usedNumbers);
			int randomIndex = (int)(GD.Randi() % this_usedNumbers.Count);
			int randomNumber = this_usedNumbers[randomIndex];
			this_usedNumbers.RemoveAt(randomIndex);
			GetNode<Label>("Window/Label").Text = randomNumber.ToString() + "号";
			GetNode<Label>("Label").Text = "抽到学号：" + randomNumber.ToString() + "号";
			GD.Print("抽到学号：", randomNumber);
			GD.Print("剩余学号：", String.Join(", ", this_usedNumbers));
			GD.Print("剩余数组大小：", this_usedNumbers.Count, "\n");
		}
		else
		{
			GD.Print("学号抽完了，无法继续抽取");
		}
	}

	private void RamdSum()
	{
		if (usedNumbers.Count > 0)
		{
			GenId(usedNumbers);
		}
		else
		{
			GD.Print("学号抽完了，重新填充数组");
			ResetIdTable();
			GenId(usedNumbers);
		}
	}

	private void ResetIdTable()
	{
		usedNumbers = new List<int>(numbers);
	} 

	private void CloseWindow()
	{
		GetNode<Window>("Window").Visible = false;
		timer.Stop();
	}
	
	private void CloseSplashText()
	{
		GetNode<Label>("Label").Text = " ";
		splashTimer.Stop();
	}
	
	public void _OnButtonDown()
	{
		RamdSum();
		GetNode<Window>("Window").Visible = true;
		timer.Start();
	}

	private void CleanText()
	{
		timerText.Stop();
		GetNode<Label>("Label").Text = " ";
	}

	public void _OnResetButtonDown()
	{
		ResetIdTable();
		GD.Print("重置按钮被点击");
		GD.Print("剩余学号：", String.Join(", ", usedNumbers));
		GD.Print("剩余数组大小：", usedNumbers.Count);
		GetNode<Label>("Label").Text = "  重置成功！";
		timerResetText.Start();
	}

	private void CleanResetText()
	{
		GetNode<Label>("Label").Text = " ";
		timerResetText.Stop();
	}
}